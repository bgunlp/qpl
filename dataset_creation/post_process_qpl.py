import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional

import regex as re


def post_process(flat_qpl: List[str]) -> List[str]:
    flat_qpl_scan_pattern = re.compile(
        r"#(?P<idx>\d+) = Scan Table \[ (?P<table>\w+) \]( Predicate \[ (?P<pred>[^\]]+) \])?( Distinct \[ (?P<distinct>true) \])? Output \[ (?P<out>[^\]]+) \]"
    )
    flat_qpl_line_pattern = re.compile(
        r"#(?P<idx>\d+) = (?P<op>\w+) \[ (?P<ins>[^\]]+) \] ((?P<opt>\w+) \[ (?P<arg>[^\]]+) \] )*Output \[ (?P<out>[^\]]*) \]"
    )
    outputs_pattern = re.compile(r"Output \[ (?P<out>[^\]]*) \]")
    agg_pattern = re.compile(
        r"((?P<agg>MIN|MAX|COUNT|AVG|SUM)\((?P<distinct>DISTINCT )?)?(?P<table>[a-zA-Z_]\w+)\.(?P<col>\w+)\)?|(countstar)"
    )
    fully_qualified_pattern = re.compile(
        r"(?P<table>\w+)\.(?P<col>[a-zA-Z_%][a-zA-Z0-9_%]*)"
    )
    arith_pattern = re.compile(
        r"((?P<lhs_table>\w+)\.(?P<lhs_col>\w+)) (?P<op>[+\-*/]) ((?P<rhs_table>\w+)\.(?P<rhs_col>\w+))"
    )
    order_by_pattern = re.compile(r"(?P<cr>.*)(?=DESC|ASC)(?P<dir>DESC|ASC)")
    line_str_no_opts = "#{idx} = {op} [ {ins} ] Output [ {output} ]"
    line_str_opts = "#{idx} = {op} [ {ins} ] {options} Output [ {output} ]"

    agg2idx: Dict[str, int] = {}

    arith_ops = {"+": "Sum", "-": "Diff", "*": "Prod", "/": "Div"}
    arith_ids: Dict[str, int] = defaultdict(int)
    arith_cache: Dict[int, Dict[str, str]] = defaultdict(dict)

    def extract_outputs(line: str) -> List[str]:
        if m := outputs_pattern.search(line):
            outs = m.groupdict()["out"].split(" , ")
            return outs
        raise ValueError("Returning empty output list from extract_outputs")

    def index_predicate(predicate: str, ins: List[int]) -> str:
        new_components = []
        first_arith_cache_copy = arith_cache[ins[0]].copy()
        second_arith_cache_copy = arith_cache[ins[1]].copy()
        assigned_top_bottom = set()
        if m := re.match(r"((#\d+)|(\w+))\.(\w+) = \1\.\4", predicate):
            return f"#{ins[0]}.{m.group(4)} = #{ins[1]}.{m.group(4)}"
        for comp in re.split(r"(<>|>=|<=|=|>|<|IS NULL OR|IS| OR|AND)", predicate):
            comp = comp.strip()
            first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
            second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])

            if m := arith_pattern.match(comp):
                (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                k = f"{lhs_col} {operator} {rhs_col}"
                if v := first_arith_cache_copy.get(k):
                    first_arith_cache_copy.pop(k)
                    new_components.append(f"#{ins[0]}.{v}")
                elif v := second_arith_cache_copy.get(k):
                    second_arith_cache_copy.pop(k)
                    new_components.append(f"#{ins[1]}.{v}")
                else:
                    raise AssertionError(f"Arithmetic expression problem in {id_ = }")
            elif m := fully_qualified_pattern.match(comp):
                gd = m.groupdict()
                table = gd["table"]
                col = gd["col"]
                k = f"{table}.{col}"
                if k in first_input_outputs:
                    new_components.append(f"#{ins[0]}.{col}")
                    first_input_outputs.remove(k)
                elif k in second_input_outputs:
                    new_components.append(f"#{ins[1]}.{col}")
                    second_input_outputs.remove(k)
                elif m := re.match(r"(T|B)\.(\w+)", comp):
                    (_, col) = m.groups()
                    col = "Count_Star" if col == "countstar" else col
                    if ins[0] not in assigned_top_bottom:
                        new_components.append(f"#{ins[0]}.{col}")
                        assigned_top_bottom.add(ins[0])
                    else:
                        new_components.append(f"#{ins[1]}.{col}")
                        assigned_top_bottom.add(ins[1])
                else:
                    raise ValueError(
                        "Predicate uses columns not available in the inputs"
                    )
            elif m := agg_pattern.match(comp):
                gd = m.groupdict()
                agg = gd["agg"]
                table = gd["table"]
                col = gd["col"]
                key = f"{agg}({table}.{col})"
                if key in first_input_outputs:
                    new_components.append(f"#{ins[0]}.{agg.title()}_{col}")
                    first_input_outputs.remove(key)
                elif key in second_input_outputs:
                    new_components.append(f"#{ins[1]}.{agg.title()}_{col}")
                    second_input_outputs.remove(key)
                else:
                    print("PROBLEM", comp)
            else:
                new_components.append(comp)
        return " ".join(new_components)

    def index_output_list(output_list: List[str], ins: List[int]) -> List[str]:
        indexed_output_list = []
        first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
        second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])
        for out in output_list:
            if m := arith_pattern.match(out):
                (_, lhs_table, lhs_col, operator, _, rhs_table, rhs_col) = m.groups()
                if (k := f"{lhs_col} {operator} {rhs_col}") in arith_cache[ins[0]]:
                    indexed_output_list.append(f"#{ins[0]}.{arith_cache[ins[0]][k]}")
                elif (k := f"{lhs_col} {operator} {rhs_col}") in arith_cache[ins[1]]:
                    indexed_output_list.append(f"#{ins[1]}.{arith_cache[ins[1]][k]}")
                else:
                    new_arith = []
                    for t, c in [(lhs_table, lhs_col), (rhs_table, rhs_col)]:
                        k = f"{t}.{c}"
                        if k in first_input_outputs:
                            new_arith.append(f"#{ins[0]}.{c}")
                        elif k in second_input_outputs:
                            new_arith.append(f"#{ins[1]}.{c}")
                        else:
                            print(arith_cache)
                            print(out)
                            print(first_input_outputs, second_input_outputs)
                            raise ValueError("WAT")
                    new_arith.insert(1, operator)
                    arith_ids[operator] += 1
                    k = f"{arith_ops[operator]}_{arith_ids[operator]}"
                    indexed_output_list.append(f"{' '.join(new_arith)} AS {k}")
                    arith_cache[idx][" ".join(new_arith)] = k
            elif m := fully_qualified_pattern.match(out):
                if out in first_input_outputs:
                    indexed_output_list.append(f"#{ins[0]}.{m.groupdict()['col']}")
                elif out in second_input_outputs:
                    indexed_output_list.append(f"#{ins[1]}.{m.groupdict()['col']}")
                else:
                    # FIXME: What if the output is not in the inputs?
                    print("index_output_list:", out)
            elif m := agg_pattern.match(out):
                g = m.groupdict()
                if agg := g["agg"]:
                    if g["distinct"]:
                        key = f"{agg.title()}_Dist_{g['col']}"
                        indexed_output_list.append(f"#{agg2idx[key]}.{key}")
                    else:
                        key = f"{agg.title()}_{g['col']}"
                        indexed_output_list.append(f"#{agg2idx[key]}.{key}")
                else:
                    if any(
                        [
                            out == "countstar"
                            for out in first_input_outputs + second_input_outputs
                        ]
                    ):
                        indexed_output_list.append(
                            f"#{agg2idx['Count_Star']}.Count_Star"
                        )
                    else:
                        indexed_output_list.append("1 AS One")
            else:
                # FIXME: Take care of non-aggregates or FQs
                pass
        return indexed_output_list

    def replace_fqs_and_aggs(predicate: str, ins: List[int]) -> str:
        new_components = []
        is_negation = False
        if m := re.match(r"NOT \((.*)\)", predicate):
            (predicate,) = m.groups()
            is_negation = True
        for comp in predicate.split():
            if comp == "countstar":
                new_components.append("Count_Star")
            elif m := fully_qualified_pattern.match(comp):
                (_, col) = m.groups()
                new_components.append(col)
            elif m := agg_pattern.match(comp):
                (_, agg, _, _, col, _) = m.groups()
                new_components.append(f"{agg.title()}_{col}")
            else:
                new_components.append(comp)
        if is_negation:
            return f"NOT ({' '.join(new_components)})"
        return " ".join(new_components)

    def replace_order_by(order_by: List[str], ins: List[int]) -> List[str]:
        new_order_by = []
        for ob in order_by:
            if m := order_by_pattern.match(ob):
                cr = m.groupdict()["cr"].strip()
                dir_ = m.groupdict()["dir"]
                if cr == "countstar":
                    new_order_by.append(f"Count_Star {dir_}")
                elif m := arith_pattern.match(cr):
                    (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                    k = f"{lhs_col} {operator} {rhs_col}"
                    if v := arith_cache[ins[0]].get(k):
                        new_order_by.append(f"{v} {dir_}")
                    else:
                        original_outs = extract_outputs(flat_qpl[ins[0] - 1])
                        if cr in original_outs:
                            new_line = new_lines[ins[0] - 1]
                            d = dict(zip(original_outs, extract_outputs(new_line)))
                            if " AS " in d[cr]:
                                ob = f"{d[cr].split(' AS ')[1]} {dir_}"
                            else:
                                ob = f"{d[cr]} {dir_}"
                            new_order_by.append(ob)
                        else:
                            raise ValueError("Don't know what to do here")
                elif m := fully_qualified_pattern.match(cr):
                    new_order_by.append(f"{m.groupdict()['col']} {dir_}")
                elif m := agg_pattern.match(cr):
                    (_, agg, _, table, col, _) = m.groups()
                    new_order_by.append(f"{agg.title()}_{col} {dir_}")
                else:
                    raise NotImplementedError
            else:
                # BUG: This should never happen
                raise NotImplementedError(
                    "Impossible situation in replace_order_by:", ob
                )
        return new_order_by

    def create_scan_line(
        idx: int,
        table: str,
        predicate: Optional[str],
        distinct: bool,
        output_list: List[str],
    ) -> str:
        new_output_list = []
        for out in output_list:
            if m := arith_pattern.match(out):
                (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                arith_ids[operator] += 1
                k = f"{arith_ops[operator]}_{arith_ids[operator]}"
                new_output_list.append(f"{lhs_col} {operator} {rhs_col} AS {k}")
                arith_cache[idx][f"{lhs_col} {operator} {rhs_col}"] = k
            elif m := fully_qualified_pattern.match(out):
                _, col = m.groups()
                new_output_list.append(col)
        if predicate:
            predicate = fully_qualified_pattern.sub(r"\2", predicate)
            pred_str = f"Predicate [ {predicate} ] "
        else:
            pred_str = ""
        if distinct:
            dist_str = f"Distinct [ true ] "
        else:
            dist_str = ""

        return f"#{idx} = Scan Table [ {table} ] {pred_str}{dist_str}Output [ {' , '.join(new_output_list)} ]"

    def create_non_atomic_line(
        idx: int,
        op: str,
        ins: List[int],
        option_names: List[str],
        args: List[str],
        output_list: List[str],
    ) -> str:
        opts = dict(zip(option_names, args))
        if op == "Aggregate":
            new_output_list = []
            for out in output_list:
                if m := fully_qualified_pattern.match(out):
                    new_output_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        out = f"{agg}({g['col']})"
                        if g["distinct"] or opts.get("Distinct"):
                            new_output_list.append(
                                f"{out.replace('(', '(DISTINCT ')} AS {agg.title()}_Dist_{g['col']}"
                            )
                            agg2idx[f"{agg.title()}_Dist_{g['col']}"] = idx
                        else:
                            new_output_list.append(f"{out} AS {agg.title()}_{g['col']}")
                            agg2idx[f"{agg.title()}_{g['col']}"] = idx
                    else:
                        new_output_list.append("countstar AS Count_Star")
                        agg2idx["Count_Star"] = idx
                else:
                    # FIXME: Take care of non-aggregates or FQs
                    print("Aggregate: Creating Output List:", out)

            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                    ),
                    output=" , ".join(new_output_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_output_list),
                )
        elif op == "Except":
            predicate = opts.get("Predicate")
            except_col = opts.get("ExceptColumns")
            if predicate:
                indexed_predicate = [
                    index_predicate(p, ins) for p in predicate.split(" , ")
                ]
                indexed_predicate = [
                    ip
                    for ip in indexed_predicate
                    if not re.match(r"(#\d+\.\w+) = \1", ip)
                ]
                args[args.index(predicate)] = indexed_predicate[0]
            elif except_col:
                args[args.index(except_col)] = " , ".join(
                    index_output_list(except_col.split(" , "), ins)
                )
            else:
                pass
            new_output_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                    ),
                    output=" , ".join(new_output_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_output_list),
                )
        elif op == "Filter":
            predicate = opts["Predicate"]
            new_predicate = replace_fqs_and_aggs(predicate, ins)
            args[args.index(predicate)] = new_predicate
            new_output_list = []
            for out in output_list:
                if out == "1":
                    new_output_list.append("1 AS One")
                elif m := fully_qualified_pattern.match(out):
                    new_output_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    gd = m.groupdict()
                    if agg := gd["agg"]:
                        if gd["distinct"]:
                            new_output_list.append(f"{agg.title()}_Dist_{gd['col']}")
                        else:
                            new_output_list.append(f"{agg.title()}_{gd['col']}")
                    else:
                        new_output_list.append("Count_Star")
                else:
                    print("Filter: Output List Creation:", out)
                    new_output_list.append(out)
            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                ),
                output=" , ".join(new_output_list),
            )
        elif op == "Intersect":
            predicate = opts.get("Predicate")
            if predicate:
                indexed_predicate = index_predicate(predicate, ins)
                args[args.index(predicate)] = indexed_predicate
            new_output_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                    ),
                    output=" , ".join(new_output_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_output_list),
                )
        elif op == "Join":
            predicate = opts.get("Predicate")
            if predicate:
                indexed_predicate = [
                    index_predicate(p, ins) for p in predicate.split(" , ")
                ]
                args[args.index(predicate)] = " AND ".join(indexed_predicate)
            if not output_list:
                output_list = []
                first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
                second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])
                seen_cols = set()
                for out in first_input_outputs + second_input_outputs:
                    if m := fully_qualified_pattern.match(out):
                        gd = m.groupdict()
                        col = gd["col"]
                        if col not in seen_cols:
                            seen_cols.add(col)
                            output_list.append(out)
            new_output_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                    ),
                    output=" , ".join(new_output_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_output_list),
                )
        elif op == "Sort":
            order_by = opts.get("OrderBy")
            if order_by:
                new_order_by = replace_order_by(order_by.split(" , "), ins)
                args[args.index(order_by)] = " , ".join(new_order_by)
            new_output_list = []
            for out in output_list:
                if m := fully_qualified_pattern.match(out):
                    new_output_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        if g["distinct"]:
                            raise ValueError(g)
                        new_output_list.append(f"{agg.title()}_{g['col']}")
                    else:
                        new_output_list.append("Count_Star")
                else:
                    print("Sort: Output List Creation:", out)
                    new_output_list.append(out)
            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                ),
                output=" , ".join(set(new_output_list)),
            )
        elif op == "Top":
            if not output_list:
                new_output_list = [
                    re.sub(r"#\d+\.", "", out)
                    for out in extract_outputs(new_lines[ins[0] - 1])
                ]
            else:
                new_output_list = []
                for out in output_list:
                    if m := fully_qualified_pattern.match(out):
                        new_output_list.append(m.groupdict()["col"])
                    elif m := agg_pattern.match(out):
                        g = m.groupdict()
                        if agg := g["agg"]:
                            if g["distinct"]:
                                raise ValueError(g)
                            new_output_list.append(f"{agg.title()}_{g['col']}")
                        else:
                            new_output_list.append("Count_Star")
                    else:
                        print("Top: Output List Creation:", out)
                        new_output_list.append(out)
            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                ),
                output=" , ".join(new_output_list),
            )
        elif op == "TopSort":
            order_by = opts.get("OrderBy")
            if order_by:
                new_order_by = replace_order_by(order_by.split(" , "), ins)
                args[args.index(order_by)] = " , ".join(new_order_by)
            new_output_list = []
            for out in output_list:
                if m := arith_pattern.match(out):
                    (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                    k = f"{lhs_col} {operator} {rhs_col}"
                    if v := arith_cache[ins[0]].get(k):
                        arith_cache[idx][k] = v
                        new_output_list.append(v)
                elif m := fully_qualified_pattern.match(out):
                    new_output_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        if g["distinct"]:
                            raise ValueError(g)
                        new_output_list.append(f"{agg.title()}_{g['col']}")
                    else:
                        new_output_list.append("Count_Star")
                else:
                    print(f"TopSort: {out = }")
                    new_output_list.append(out)
            if order_by:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, args)]
                    ),
                    output=" , ".join(new_output_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_output_list),
                )
        elif op == "Union":
            if not output_list:
                output_list = []
                first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
                second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])
                seen_cols = set()
                for out in first_input_outputs + second_input_outputs:
                    if m := fully_qualified_pattern.match(out):
                        gd = m.groupdict()
                        col = gd["col"]
                        if col not in seen_cols:
                            seen_cols.add(col)
                            output_list.append(f"{out}")
            new_output_list = index_output_list(output_list, ins)
            return line_str_no_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                output=" , ".join(new_output_list),
            )
        else:
            raise ValueError(f"Unrecognized op: {op}")

    new_lines = []
    for line in flat_qpl:
        if m := flat_qpl_scan_pattern.match(line):
            captures = m.capturesdict()
            idx = int(captures["idx"][0])
            table = captures["table"][0]
            predicate = captures["pred"][0] if captures["pred"] else None
            distinct = bool(captures["distinct"])
            output_list = captures["out"][0].split(" , ")
            new_lines.append(
                create_scan_line(idx, table, predicate, distinct, output_list)
            )
        elif m := flat_qpl_line_pattern.match(line):
            captures = m.capturesdict()
            idx = int(captures["idx"][0])
            op = captures["op"][0]
            ins = [int(x[1:]) for x in captures["ins"][0].split(" , ")]
            option_names = captures["opt"]
            args = captures["arg"]
            output_list = [x for x in captures["out"][0].split(" , ") if x]
            new_lines.append(
                create_non_atomic_line(idx, op, ins, option_names, args, output_list)
            )

    for i, line in enumerate(new_lines):
        if re.search(r"Output \[  \]", line):
            line = line.replace("Output [  ]", "Output [ 1 AS One ]")
            new_lines[i] = line
        outputs = extract_outputs(line)
        new_lines[i] = re.sub(
            r"Output \[ ([^\]]+) \]", f"Output [ {' , '.join(set(outputs))} ]", line
        )

    return new_lines


def main():
    global id_
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open(args.input) as f:
        qpls = json.load(f)

    with open("./manual-qpls.json") as f:
        manual_fixes = {x["id"]: x["qpl"] for x in json.load(f)}

    post_processed = []
    for ex in qpls:
        id_ = ex["id"]
        if id_ in [
            "1a9cb645bfb879ffd3a868fea98cfc678fb1cb96dd61d0968a54cf7a17564597",
            "f3f1ce231ea8c07331dabd8c267b0819552d2d51721a19f5236b3769cff5c05d",
        ]:
            # Problematic IDs in train set
            continue
        if id_ in manual_fixes:
            ex["qpl"] = manual_fixes[id_]
        else:
            db_id, qpl = ex["qpl"].split(" | ")
            if db_id == "hr_1":
                qpl = qpl.replace("<> 'null'", "IS NOT NULL").replace(
                    "= 'null'", "IS NULL"
                )
            try:
                result = post_process(qpl.split(" ; "))
            except AssertionError as e:
                print(e)
                continue
            else:
                ex["qpl"] = f"{db_id} | {' ; '.join(result)}"
        post_processed.append(ex)

    with open(args.output, "w") as f:
        json.dump(post_processed, f, indent=2)


if __name__ == "__main__":
    main()
