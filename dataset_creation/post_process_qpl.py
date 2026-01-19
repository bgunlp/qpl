import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional

import regex as re

from dataset_creation.ehrsql2024.util import match_and_replace


def post_process(flat_qpl: List[str]) -> List[str]:
    flat_qpl_scan_pattern = re.compile(
        r"#(?P<idx>\d+) = Scan Table \[ (?P<table>\w+) \]( Predicate \[ (?P<pred>((?!Distinct|Output).)+) \])?( Distinct \[ (?P<distinct>true) \])? Output \[ (?P<out>[^\]]+) \]"
    )
    flat_qpl_line_pattern = re.compile(
        r"#(?P<idx>\d+) = (?P<op>\w+) \[ (?P<ins>[^\]]+) \] ((?P<opt>\w+) \[ (?P<arg>[^\]]+) \] )*Output \[ (?P<out>[^\]]*) \]"
    )
    outputs_pattern = re.compile(r"Output \[ (?P<out>[^\]]*) \]")
    agg_pattern = re.compile(
        r"(((((?P<agg>MIN|MAX|COUNT|AVG|SUM)\((?P<distinct>DISTINCT )?)?((?P<table>[a-zA-Z_]\w+)\.)?(?P<col>\w+))\))|(?P<cs>countstar))( (?P<op>[+\-*\/=<>]+) (?P<num>\d+))?"
    )
    fully_qualified_pattern = re.compile(
        r"(?P<table>\w+)\.(?P<col>[a-zA-Z_%][a-zA-Z0-9_%]*)"
    )
    arith_pattern = re.compile(
        r"((?P<lhs_table>\w+)\.(?P<lhs_col>\w+)) (?P<op>[+\-*/=<>]+) ((?P<rhs_table>\w+)\.(?P<rhs_col>\w+))"
    )

    arith_pattern_complex = re.compile(
        r"(?P<lhs_func>\w+)?\(?(?P<lhs_table>\w+)\.(?P<lhs_col>\w+)\)? (?P<op>[+\-*/=<>]+) (?P<rhs_func>\w+)?\(?(?P<rhs_table>\w+)\.(?P<rhs_col>\w+)\)?"
    )
    arith_pattern_complex_2 = re.compile(
        r"(?P<lhs>\w+\((?P<lhs_table>\w+)\.\w+\)) (?P<op>[+\-*/=<>]+) (?P<rhs>\w+\((?P<rhs_table>\w+)\.\w+\))"
    )

    function_call_pattern = re.compile(
        r"((?P<num>\d+) (?P<arith_op>[+\-*/=<>]+) )?(?P<name>\w+)\((?P<args>.*)\)"
    )

    order_by_pattern = re.compile(r"(?P<cr>.*)(?=DESC|ASC)(?P<dir>DESC|ASC)")
    line_str_no_opts = "#{idx} = {op} [ {ins} ] Output [ {output} ]"
    line_str_opts = "#{idx} = {op} [ {ins} ] {options} Output [ {output} ]"

    agg2idx: Dict[str, int] = {}

    arith_ops_infix = {"+": "Plus", "-": "Minus", "*": "Mul", "/": "Div",
                       "<": "Ls", ">": "Gr", "=": "Eq", "<=": "Leq", ">=": "Geq"}

    arith_ops = {"+": "Sum", "-": "Diff", "*": "Prod", "/": "Div",
                 "<": "Ls", ">": "Gr", "=": "Eq", "<=": "Leq", ">=": "Geq"}
    arith_ids: Dict[str, int] = defaultdict(int)
    arith_cache: Dict[int, Dict[str, str]] = defaultdict(dict)

    func_ids: Dict[str, int] = defaultdict(int)     # func_ids[func_call_flat] = func_call_flat_idx (for alias)
    func_cache: Dict[int, Dict[str, str]] = defaultdict(dict)  # func_cache[QPL_line_idx][func_call] = func_call_alias (containing func_call_flat_idx)

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

        for pred in re.split(r"(OR|AND)", predicate):
            first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
            second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])
            for comp in re.split(r"(<>|>=|<=|=|>|<|IS NULL OR|IS|DURING|MEETS|MET_BY)", pred):
                comp = comp.strip()
                comp_countstar_replaced = 'Count_Star' if comp == 'countstar' else comp

                def idex_fq(match):
                    gd = match.groupdict()
                    table = gd["table"]
                    col = gd["col"]
                    k = f"{table}.{col}"
                    if k in first_input_outputs:
                        first_input_outputs.remove(k)
                        return f"#{ins[0]}.{col}"

                    elif k in second_input_outputs:
                        second_input_outputs.remove(k)
                        return f"#{ins[1]}.{col}"

                    elif m := re.match(r"(T|B)\.(\w+)", comp):
                        (_, col) = m.groups()
                        col = "Count_Star" if col == "countstar" else col
                        if ins[0] not in assigned_top_bottom:
                            assigned_top_bottom.add(ins[0])
                            return f"#{ins[0]}.{col}"

                        else:
                            assigned_top_bottom.add(ins[1])
                            return f"#{ins[1]}.{col}"

                    else:
                        print(f"Predicate uses columns not available in the inputs, predicate=[{predicate}]")
                        raise ValueError("Predicate uses columns not available in the inputs")

                if m := arith_pattern.fullmatch(comp):  # match
                    (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                    k = f"{lhs_col} {operator} {rhs_col}"
                    if v := first_arith_cache_copy.get(k):
                        first_arith_cache_copy.pop(k)
                        new_components.append(f"#{ins[0]}.{v}")
                    elif v := second_arith_cache_copy.get(k):
                        second_arith_cache_copy.pop(k)
                        new_components.append(f"#{ins[1]}.{v}")
                    else:
                        print(f"Arithmetic expression problem in {id_ = }")
                        raise AssertionError(f"Arithmetic expression problem in {id_ = }")

                elif m := agg_pattern.fullmatch(comp):  # fullmatch VS match
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

                    elif comp in first_input_outputs:  # TODO: to document this modification
                        new_components.append(f"#{ins[0]}.{comp_countstar_replaced}")
                        first_input_outputs.remove(comp)
                    elif comp in second_input_outputs:  # TODO: to document this modification
                        new_components.append(f"#{ins[1]}.{comp_countstar_replaced}")
                        second_input_outputs.remove(comp)

                    else:
                        print("PROBLEM", comp)
                else:
                    comp_indexed_fq = match_and_replace(comp, [(fully_qualified_pattern.pattern, idex_fq)])
                    new_components.append(comp_indexed_fq)

        return " ".join(new_components)

    def index_output_list(output_list: List[str], ins: List[int]) -> List[str]:
        def _index_fq(_m):
            _out = _m.group(0)
            if _out in first_input_outputs:
                return f"#{ins[0]}.{_m.groupdict()['col']}"
            elif _out in second_input_outputs:
                return f"#{ins[1]}.{_m.groupdict()['col']}"
            else:
                return _out

        out_list_indexed = []
        first_input_outputs = extract_outputs(flat_qpl[ins[0] - 1])
        second_input_outputs = extract_outputs(flat_qpl[ins[1] - 1])

        for out in output_list:
            if m := arith_pattern.match(out):
                (_, lhs_table, lhs_col, operator, _, rhs_table, rhs_col) = m.groups()

                if (k := f"{lhs_col} {operator} {rhs_col}") in arith_cache[ins[0]]:
                    out_list_indexed.append(f"#{ins[0]}.{arith_cache[ins[0]][k]}")

                elif (k := f"{lhs_col} {operator} {rhs_col}") in arith_cache[ins[1]]:
                    out_list_indexed.append(f"#{ins[1]}.{arith_cache[ins[1]][k]}")

                else:
                    new_arith = []
                    for n, (t, c) in enumerate([(lhs_table, lhs_col), (rhs_table, rhs_col)]):
                        k = f"{t}.{c}"

                        if n == 0:  # !!
                            if k in first_input_outputs:
                                new_arith.append(f"#{ins[0]}.{c}")
                            elif k in second_input_outputs:
                                new_arith.append(f"#{ins[1]}.{c}")
                            else:
                                print(arith_cache)
                                print(out)
                                print(first_input_outputs, second_input_outputs)
                                raise ValueError("WAT")
                        else:
                            if k in second_input_outputs:
                                new_arith.append(f"#{ins[1]}.{c}")
                            elif k in first_input_outputs:
                                new_arith.append(f"#{ins[0]}.{c}")
                            else:
                                print(arith_cache)
                                print(out)
                                print(first_input_outputs, second_input_outputs)
                                raise ValueError("WAT")

                    new_arith.insert(1, operator)
                    arith_ids[operator] += 1
                    k = f"{arith_ops[operator]}_{arith_ids[operator]}"
                    out_list_indexed.append(f"{' '.join(new_arith)} AS {k}")
                    arith_cache[idx][" ".join(new_arith)] = k

            elif m := arith_pattern_complex_2.match(out):
                (lhs, _, op, rhs, _) = m.groups()
                new_arith = []
                for n, k in enumerate([lhs, rhs]):
                    k_replaced = replace_fq_and_ymd_nums(k)
                    if n == 0:  # !!
                        if mf := function_call_pattern.match(k_replaced):
                            fc_gd = mf.groupdict()
                            func_call = k_replaced
                            if func_call in func_cache[ins[0]]:
                                out_list_process_existing_func_alias(idx, ins[0], func_call, fc_gd, new_arith,True)
                            elif func_call in func_cache[ins[1]]:
                                out_list_process_existing_func_alias(idx, ins[1], func_call, fc_gd, new_arith,True)
                            else:
                                print(arith_cache)
                                print(out)
                                print(first_input_outputs, second_input_outputs)
                                raise ValueError("WAT")
                        else:
                            print(f"index_output_list: A")

                    else:
                        if mf := function_call_pattern.match(k_replaced):
                            fc_gd = mf.groupdict()
                            func_call = k_replaced
                            if func_call in func_cache[ins[1]]:
                                out_list_process_existing_func_alias(idx, ins[1], func_call, fc_gd, new_arith,True)
                            elif func_call in func_cache[ins[0]]:
                                out_list_process_existing_func_alias(idx, ins[0], func_call, fc_gd, new_arith,True)
                            else:
                                print(arith_cache)
                                print(out)
                                print(first_input_outputs, second_input_outputs)
                                raise ValueError("WAT")
                        else:
                            print(f"index_output_list: A")

                new_arith.insert(1, op)
                arith_ids[op] += 1
                k = f"{arith_ops[op]}_{arith_ids[op]}"
                out_list_indexed.append(f"{' '.join(new_arith)} AS {k}")
                arith_cache[idx][" ".join(new_arith)] = k

            elif m := fully_qualified_pattern.match(out):
                if out in first_input_outputs:
                    out_list_indexed.append(f"#{ins[0]}.{m.groupdict()['col']}")
                elif out in second_input_outputs:
                    out_list_indexed.append(f"#{ins[1]}.{m.groupdict()['col']}")
                else:
                    # FIXME: What if the output is not in the inputs?
                    print("index_output_list:", out)

            elif m := agg_pattern.match(out):
                g = m.groupdict()
                if agg := g["agg"]:
                    if g["distinct"]:
                        key = f"{agg.title()}_Dist_{g['col']}"
                        out_list_indexed.append(f"#{agg2idx[key]}.{key}")
                    else:
                        key = f"{agg.title()}_{g['col']}"
                        out_list_indexed.append(f"#{agg2idx[key]}.{key}")
                else:
                    if any(
                            [
                                out == "countstar"
                                for out in first_input_outputs + second_input_outputs
                            ]
                    ):
                        out_list_indexed.append(
                            f"#{agg2idx['Count_Star']}.Count_Star"
                        )
                    else:
                        out_list_indexed.append("1 AS One")

            else:
                out_replaced = replace_fq_and_ymd_nums(out)
                if mf := function_call_pattern.match(out_replaced):
                    fc_gd = mf.groupdict()
                    func_call = out_replaced
                    if func_call in func_cache[ins[0]]:
                        out_list_process_existing_func_alias(idx, ins[0], func_call, fc_gd, out_list_indexed, True)
                    elif func_call in func_cache[ins[1]]:
                        out_list_process_existing_func_alias(idx, ins[1], func_call, fc_gd, out_list_indexed, True)
                    else:
                        # Add index to each relevant function-call argument:
                        out_fq_indexed = match_and_replace(out, [(fully_qualified_pattern.pattern, _index_fq)])
                        if out_fq_indexed != out:
                            out_fq_indexed_ymd_replaced = replace_ymd_nums(out_fq_indexed)
                            fc_gd = function_call_pattern.match(out_fq_indexed_ymd_replaced).groupdict()
                            out_list_process_new_func_alias(idx, out_fq_indexed_ymd_replaced, fc_gd, out_list_indexed)
                        else:
                            # The code probably won't reach this point:
                            out_list_process_new_func_alias(idx, func_call, fc_gd, out_list_indexed)
                            print(f"index_output_list: out=[{out}], func_call=[{func_call}], "
                                  f"alias=[{func_cache[idx][func_call]}], "
                                  f"output_list=[{str(output_list)}], ins=[{str(ins)}]\n")
                else:
                    out_fq_indexed = match_and_replace(out, [(fully_qualified_pattern.pattern, _index_fq)])
                    out_list_indexed.append(out_fq_indexed)
                    print(f"index_output_list: out_fq_indexed={out_fq_indexed}")

        return out_list_indexed

    def replace_fqs_and_aggs(predicate: str, ins: List[int]) -> str:
        new_components = []
        is_negation = False
        if m := re.match(r"NOT \((.*)\)", predicate):
            (predicate,) = m.groups()
            is_negation = True

        predicate_split = predicate.split()
        for comp in predicate_split:
            if comp == "countstar":
                new_components.append("Count_Star")
            elif m := fully_qualified_pattern.fullmatch(comp):  # fullmatch VS match
                (_, col) = m.groups()
                new_components.append(col)
            elif (m := agg_pattern.fullmatch(comp)) and \
                 (len(m.groups()) == 6)             and \
                 (m.groups()[1] is not None)        and \
                 (m.groups()[4] is not None):
                (_, agg, _, _, col, _) = m.groups()
                new_components.append(f"{agg.title()}_{col}")
            else:
                comp_new = replace_fully_qualified(comp)
                new_components.append(comp_new)

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

                elif m := agg_pattern.match(cr):
                    (_, agg, _, table, col, _) = m.groups()
                    new_order_by.append(f"{agg.title()}_{col} {dir_}")
                else:
                    new_order_by.append(ob)
            else:
                # BUG: This should never happen
                raise NotImplementedError(
                    "Impossible situation in replace_order_by:", ob
                )
        return new_order_by

    def replace_fq_and_ymd_nums(qpl: str) -> str:
        qpl_replaced_ymd = replace_ymd_nums(qpl)
        qpl_replaced_ymd_fq = replace_fully_qualified(qpl_replaced_ymd)
        return qpl_replaced_ymd_fq

    def replace_ymd_nums(qpl: str) -> str:
        def num_for_ymd_replacer(match):
            num_to_ymd = {
                '0': 'year',
                '2': 'month',
                '4': 'day',
            }
            func_name = match.group('func_name')
            num = match.group('num')
            if func_name == 'datepart':
                return f'{num_to_ymd[num]}('
            return f'{func_name}({num_to_ymd[num]}, '

        num_for_ymd_pattern = r'(?P<func_name>datediff|dateadd|datepart)\((?P<num>\d), '
        return match_and_replace(qpl, [
            (num_for_ymd_pattern, num_for_ymd_replacer)
        ])

    def replace_fully_qualified(qpl: str) -> str:
        return match_and_replace(qpl, [
            (fully_qualified_pattern.pattern, lambda match: match.group('col'))
        ])

    def replace_agg(qpl: str) -> str:
        # TODO: maybe verify that it exist as a previous output, as with 'key' in index_predicate
        def agg_replacer(match):
            gd = match.groupdict()
            if gd['agg'] is not None and gd['col'] is not None:
                return f"{gd['agg'].title()}_{gd['col']}"
            return match.group(0)

        return match_and_replace(qpl, [
            ('countstar', 'Count_Star'),
            (agg_pattern.pattern, agg_replacer)
        ])

    def flatten_func_call(func_call_gd: Dict[str, str]) -> str:
        def signed_num_replacer(match):
            sign = match.group('sign')
            num = match.group('num')
            return f'{arith_ops_infix[sign]}_{num}'

        signed_num_pattern = re.compile(r"(?P<sign>[-+])(?P<num>\d+)")
        func_args_pattern = re.compile(r"[a-zA-Z0-9_%#]+")  # #

        num = func_call_gd['num']
        arith_op = func_call_gd['arith_op']
        func_name = func_call_gd['name']
        func_args = func_call_gd['args']

        func_call_flat = func_name
        if is_func_call_inside_arith := (num is not None) and (arith_op is not None):
            func_call_flat = f"_{num}_{arith_ops_infix[arith_op]}_{func_name}"

        args_replaced = match_and_replace(func_args, [
            (signed_num_pattern.pattern, signed_num_replacer),
            # (r"\.", "_")
        ])
        if matches := func_args_pattern.findall(args_replaced):
            args_flat = '_'.join(matches)
            func_call_flat = f"{func_call_flat}_{args_flat}"
        else:
            if (func_args is not None) and (func_args != ''):
                print(f"flatten_func_call: func_args={func_args}")

        return func_call_flat

    def add_func_alias(idx: int, func_call: str, alias: str, func_call_flat: str) -> None:
        func_cache[idx][func_call] = alias
        func_ids[func_call_flat] += 1

    def out_list_process_new_func_alias(idx: int,
                                        func_call: str, func_call_gd: Dict[str, str],
                                        out_list: List[str]) -> None:

        func_call_flat = flatten_func_call(func_call_gd)
        alias_new = f"{func_call_flat}_{func_ids[func_call_flat] + 1}"  # create new alias
        out_aliased = f"{func_call} AS {alias_new}"
        out_list.append(out_aliased)  # add ALIASED-OUTPUT to output list

        add_func_alias(idx, func_call, alias_new, func_call_flat)  # send new alias to cache

    def out_list_process_existing_func_alias(idx: int, idx_in: int,
                                             func_call: str, func_call_gd: Dict[str, str],
                                             out_list: List[str], is_indexed_output: bool = False) -> None:

        alias_existing = func_cache[idx_in][func_call]  # retrieve existing alias
        out = f"#{idx_in}.{alias_existing}" if is_indexed_output else alias_existing
        out_list.append(out)  # add EXISTING ALIAS to output list

        func_call_flat = flatten_func_call(func_call_gd)
        add_func_alias(idx, func_call, alias_existing, func_call_flat)  # send existing alias to cache

    def create_scan_line(
            idx: int,
            table: str,
            predicate: Optional[str],
            distinct: bool,
            output_list: List[str],
    ) -> str:
        new_out_list = []
        for out in output_list:
            if m := arith_pattern.match(out):
                (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                arith_ids[operator] += 1
                k = f"{arith_ops[operator]}_{arith_ids[operator]}"
                new_out_list.append(f"{lhs_col} {operator} {rhs_col} AS {k}")
                arith_cache[idx][f"{lhs_col} {operator} {rhs_col}"] = k

            elif m := fully_qualified_pattern.match(out):  # match VS searcי
                _, col = m.groups()
                new_out_list.append(col)
            else:
                out_replaced = replace_fq_and_ymd_nums(out)
                if mf := function_call_pattern.match(out_replaced):
                    func_call = out_replaced
                    out_list_process_new_func_alias(idx, func_call, mf.groupdict(), new_out_list)
                else:
                    new_out_list.append(out_replaced)
                    print(f"create_scan_line: out_replaced={out_replaced}")

        if predicate:
            predicate = fully_qualified_pattern.sub(r"\2", predicate)
            pred_str = f"Predicate [ {predicate} ] "
        else:
            pred_str = ""
        if distinct:
            dist_str = f"Distinct [ true ] "
        else:
            dist_str = ""

        return f"#{idx} = Scan Table [ {table} ] {pred_str}{dist_str}Output [ {' , '.join(new_out_list)} ]"

    def create_non_atomic_line(
            idx: int,
            op: str,
            ins: List[int],
            option_names: List[str],
            option_args: List[str],
            output_list: List[str],
    ) -> str:
        def _create_non_atomic_line(_idx: int, _op: str, _ins: List[int], _option_names: List[str],
                                    _option_args: List[str], _output_list: List[str]) -> str:
            return line_str_opts.format(
                idx=_idx,
                op=_op,
                ins=" , ".join([f"#{i}" for i in _ins]),
                options=" ".join(
                    [f"{_n} [ {_args} ]" for _n, _args in zip(_option_names, _option_args)]
                ),
                output=" , ".join(_output_list),
            )

        def _replace_func_call_with_alias(_qpl: str) -> str:
            def func_call_to_alias_replacer(match):
                _func_call = match.group(0)
                if _func_call in func_cache[ins[0]]:
                    _alias_existing = func_cache[ins[0]][_func_call]  # retrieve existing alias
                    _func_call = _alias_existing
                return _func_call

            return match_and_replace(_qpl, [
                (function_call_pattern.pattern, func_call_to_alias_replacer),
                (agg_pattern.pattern, func_call_to_alias_replacer)
            ])

        def _replace_inner_func_call_with_alias(_qpl: str) -> str:  # r"((?P<num>\d+) (?P<arith_op>[+\-*/=<>]+) )?(?P<name>\w+)\((?P<args>.*)\)"  match.group(0)
            def inner_func_call_to_alias_replacer(match):
                _gd = match.groupdict()
                num = f"{_gd['num']} " if _gd['num'] is not None else ""
                arith_op = f"{_gd['arith_op']} " if _gd['arith_op'] is not None else ""
                name = _gd['name']
                args = _gd['args']
                args_replaced = _replace_func_call_with_alias(args)
                return f"{num}{arith_op}{name}({args_replaced})"

            return match_and_replace(_qpl, [
                (function_call_pattern.pattern, inner_func_call_to_alias_replacer)
            ])

        def _repalce_option_args(_option_args: List[str], _option_names: List[str]):
            _option_args_new = []
            for _arg in _option_args:
                _arg_new = replace_fq_and_ymd_nums(_arg)
                if _mf := function_call_pattern.match(_arg_new):
                    _func_call = _arg_new
                    if _func_call in func_cache[ins[0]]:
                        _alias_existing = func_cache[ins[0]][_func_call]  # retrieve existing alias
                        _arg_new = _alias_existing
                _option_args_new.append(_arg_new)
            option_new = dict(zip(_option_names, _option_args_new))
            return _option_args_new, option_new

        opts = dict(zip(option_names, option_args))

        if op == "Aggregate":
            option_args, opts = _repalce_option_args(option_args, option_names)

            new_out_list = []
            for out in output_list:
                out_replaced = replace_fq_and_ymd_nums(out)
                out_replaced = _replace_inner_func_call_with_alias(out_replaced)
                alias = None

                if m := agg_pattern.match(out_replaced):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        out_replaced = f"{agg}({g['col']})"
                        if g["distinct"] or opts.get("Distinct"):
                            out_replaced = out_replaced.replace('(', '(DISTINCT ')
                            alias = f"{agg.title()}_Dist_{g['col']}"
                        else:
                            alias = f"{agg.title()}_{g['col']}"

                    elif g["cs"] is not None:
                        out_replaced = 'countstar'
                        alias = f"Count_Star"

                    else:
                        # TODO: probably the code can't reach this point now:
                        print(f"Aggregate, Creating Output List, out_replaced=[{out_replaced}]")
                        raise ValueError(f"Aggregate, Creating Output List, out_replaced=[{out_replaced}]")

                    if (opr := g["op"]) and (n := g["num"]):
                        out_replaced = f"{out_replaced} {opr} {n}"
                        alias = f"{alias}_{arith_ops[opr]}_{n}"

                    add_func_alias(idx, func_call=out_replaced, alias=alias, func_call_flat=alias)

                if alias is not None:
                    agg2idx[alias] = idx
                    out_new = f"{out_replaced} AS {alias}"
                else:
                    out_new = out_replaced
                new_out_list.append(out_new)

            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                    ),
                    output=" , ".join(new_out_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_out_list),
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
                option_args[option_args.index(predicate)] = indexed_predicate[0]
            elif except_col:
                option_args[option_args.index(except_col)] = " , ".join(
                    index_output_list(except_col.split(" , "), ins)
                )
            else:
                pass
            new_out_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                    ),
                    output=" , ".join(new_out_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_out_list),
                )

        elif op == "Filter":
            option_args, opts = _repalce_option_args(option_args, option_names)

            predicate = opts["Predicate"]
            predicate_replaced_fqs_and_aggs = replace_fqs_and_aggs(predicate, ins)
            predicate_new = _replace_func_call_with_alias(predicate_replaced_fqs_and_aggs)
            option_args[option_args.index(predicate)] = predicate_new

            new_out_list = []
            for out in output_list:  #####
                if out == "1":
                    new_out_list.append("1 AS One")
                elif m := fully_qualified_pattern.match(out):
                    new_out_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    gd = m.groupdict()
                    if agg := gd["agg"]:
                        if gd["distinct"]:
                            new_out_list.append(f"{agg.title()}_Dist_{gd['col']}")
                        else:
                            new_out_list.append(f"{agg.title()}_{gd['col']}")
                    else:
                        new_out_list.append("Count_Star")
                else:
                    out_replaced = replace_fq_and_ymd_nums(out)
                    if mf := function_call_pattern.match(out_replaced):
                        func_call = out_replaced
                        if func_call in func_cache[ins[0]]:
                            out_list_process_existing_func_alias(idx, ins[0], func_call, mf.groupdict(), new_out_list)
                        else:
                            out_list_process_new_func_alias(idx, func_call, mf.groupdict(), new_out_list)
                    else:
                        new_out_list.append(out_replaced)
                        print(f"create_non_atomic_line/Filter: out_replaced={out_replaced}")

            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                ),
                output=" , ".join(new_out_list),
            )

        elif op == "Intersect":
            predicate = opts.get("Predicate")
            if predicate:
                indexed_predicate = index_predicate(predicate, ins)
                option_args[option_args.index(predicate)] = indexed_predicate
            new_out_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                    ),
                    output=" , ".join(new_out_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_out_list),
                )

        elif op == "Join":
            predicate = opts.get("Predicate")
            if predicate:
                indexed_predicate = [
                    index_predicate(p, ins) for p in predicate.split(" , ")
                ]
                option_args[option_args.index(predicate)] = " AND ".join(indexed_predicate)

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
            new_out_list = index_output_list(output_list, ins)
            if option_names:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                    ),
                    output=" , ".join(new_out_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_out_list),
                )

        elif op == "Sort":
            option_args, opts = _repalce_option_args(option_args, option_names)

            order_by = opts.get("OrderBy")
            if order_by:
                new_order_by = replace_order_by(order_by.split(" , "), ins)
                option_args[option_args.index(order_by)] = " , ".join(new_order_by)

            new_out_list = []
            for out in output_list:
                if m := fully_qualified_pattern.match(out):
                    new_out_list.append(m.groupdict()["col"])

                elif m := agg_pattern.match(out):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        if g["distinct"]:
                            raise ValueError(g)
                        new_out_list.append(f"{agg.title()}_{g['col']}")
                    else:
                        new_out_list.append("Count_Star")

                else:
                    print("Sort: Output List Creation:", out)
                    new_out_list.append(out)

            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                ),
                output=" , ".join(list(dict.fromkeys(new_out_list))),  # " , ".join(set(new_out_list)),  [*]
            )

        elif op == "Top":
            option_args, opts = _repalce_option_args(option_args, option_names)

            if not output_list:
                new_out_list = [
                    re.sub(r"#\d+\.", "", out)
                    for out in extract_outputs(new_lines[ins[0] - 1])
                ]
            else:
                new_out_list = []
                for out in output_list:
                    # if m := fully_qualified_pattern.match(out):
                    #     new_out_list.append(m.groupdict()["col"])
                    out_new = replace_fq_and_ymd_nums(out)
                    alias_new = None

                    # if out_new == 'countstar':
                    #     alias_new = f"Count_Star"

                    if m := agg_pattern.match(out_new):
                        g = m.groupdict()
                        if agg := g["agg"]:
                            if g["distinct"]:
                                raise ValueError(g)
                            out_new = f"{agg}({g['col']})"
                            alias_new = f"{agg.title()}_{g['col']}"

                        elif g["cs"] is not None:
                            out_new = 'countstar'
                            alias_new = f"Count_Star"

                        else:
                            # TODO: probably the code can't reach this point now:
                            raise ValueError(f"Top, Creating Output List, out_new=[{out_new}]")

                        ################################
                        # TODO: extract method ??
                        if out_new in func_cache[ins[0]]:
                            alias_existing = func_cache[ins[0]][out_new]  # retrieve existing alias
                            out_new = alias_existing
                            alias_new = alias_existing
                        ################################

                        if (opr := g["op"]) and (n := g["num"]):
                            out_new = f"{out_new} {opr} {n}"
                            alias_new = f"{alias_new}_{arith_ops[opr]}_{n}"
                            # out_new = f"{out_raw} AS {alias_new}"

                        ################################
                        # TODO: extract method ??
                        if out_new in func_cache[ins[0]]:
                            alias_existing = func_cache[ins[0]][out_new]  # retrieve existing alias
                            out_new = alias_existing
                            alias_new = alias_existing
                        ################################

                        add_func_alias(idx, func_call=out_new, alias=alias_new, func_call_flat=alias_new)

                    if alias_new is not None:
                        agg2idx[alias_new] = idx
                        out_new = f"{out_new} AS {alias_new}"

                    new_out_list.append(out_new)

            return line_str_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                options=" ".join(
                    [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                ),
                output=" , ".join(new_out_list),
            )

        elif op == "TopSort":
            option_args, opts = _repalce_option_args(option_args, option_names)

            order_by = opts.get("OrderBy")
            if order_by:
                new_order_by = replace_order_by(order_by.split(" , "), ins)
                option_args[option_args.index(order_by)] = " , ".join(new_order_by)
            new_out_list = []
            for out in output_list:
                if m := arith_pattern.match(out):
                    (_, _, lhs_col, operator, _, _, rhs_col) = m.groups()
                    k = f"{lhs_col} {operator} {rhs_col}"
                    if v := arith_cache[ins[0]].get(k):
                        arith_cache[idx][k] = v
                        new_out_list.append(v)
                elif m := fully_qualified_pattern.match(out):
                    new_out_list.append(m.groupdict()["col"])
                elif m := agg_pattern.match(out):
                    g = m.groupdict()
                    if agg := g["agg"]:
                        if g["distinct"]:
                            raise ValueError(g)
                        new_out_list.append(f"{agg.title()}_{g['col']}")
                    else:
                        new_out_list.append("Count_Star")
                else:
                    out_replaced = replace_fq_and_ymd_nums(out)
                    if mf := function_call_pattern.match(out_replaced):
                        func_call = out_replaced
                        if func_call in func_cache[ins[0]]:
                            out_list_process_existing_func_alias(idx, ins[0], func_call, mf.groupdict(), new_out_list)
                        else:
                            out_list_process_new_func_alias(idx, func_call, mf.groupdict(), new_out_list)
                    else:
                        new_out_list.append(out_replaced)
                        print(f"create_non_atomic_line/TopSort: out_replaced={out_replaced}")

            if order_by:
                return line_str_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    options=" ".join(
                        [f"{n} [ {args} ]" for n, args in zip(option_names, option_args)]
                    ),
                    output=" , ".join(new_out_list),
                )
            else:
                return line_str_no_opts.format(
                    idx=idx,
                    op=op,
                    ins=" , ".join([f"#{i}" for i in ins]),
                    output=" , ".join(new_out_list),
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
            new_out_list = index_output_list(output_list, ins)
            return line_str_no_opts.format(
                idx=idx,
                op=op,
                ins=" , ".join([f"#{i}" for i in ins]),
                output=" , ".join(new_out_list),
            )

        elif op == "SequenceProject":
            option_args, opts = _repalce_option_args(option_args, option_names)
            option_args_new = [replace_agg(arg) for arg in option_args]

            ###############
            # TODO: ecxtract method 'create_new_output_list()':
            output_list_new = []
            for out in output_list:
                out_replaced = replace_fq_and_ymd_nums(out)
                if mf := function_call_pattern.match(out_replaced):
                    func_call = out_replaced
                    if func_call in func_cache[ins[0]]:
                        out_list_process_existing_func_alias(idx, ins[0], func_call, mf.groupdict(), output_list_new)
                    else:
                        out_list_process_new_func_alias(idx, func_call, mf.groupdict(), output_list_new)
                else:
                    output_list_new.append(out_replaced)
            ###############

            return _create_non_atomic_line(idx, op, ins, option_names, option_args_new, output_list_new)

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
            output_str = captures["out"][0]
            output_list = [x for x in output_str.split(" , ") if x]
            new_lines.append(
                create_non_atomic_line(idx, op, ins, option_names, args, output_list)
            )

    for i, line in enumerate(new_lines):
        if re.search(r"Output \[  \]", line):
            line = line.replace("Output [  ]", "Output [ 1 AS One ]")
            new_lines[i] = line

        outputs = extract_outputs(line)
        # new_lines[i] = re.sub(
        #     r"Output \[ ([^\]]+) \]", f"Output [ {' , '.join(set(outputs))} ]", line
        # )
        # TODO: for debug (maybe good to keep not only for debug)  [*]
        new_lines[i] = re.sub(
            r"Output \[ ([^\]]+) \]", f"Output [ {' , '.join(list(dict.fromkeys(outputs)))} ]", line
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
                result = post_process(qpl.split(" , "))
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
