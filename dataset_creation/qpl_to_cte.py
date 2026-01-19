import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import List

import regex as re

from dataset_creation.ehrsql2024.util import match_and_replace


@dataclass
class CTE:
    name: str
    query: str


def flat_qpl_to_cte(flat_qpl: List[str], db_id: str) -> str:
    flat_qpl_scan_pattern = re.compile(
        r"#(?P<idx>\d+) = Scan Table \[ (?P<table>\w+) \]( Predicate \[ (?P<pred>((?!Distinct|Output).)+) \])?( Distinct \[ (?P<distinct>true) \])? Output \[ (?P<out>[^\]]+) \]"
    )
    flat_qpl_line_pattern = re.compile(
        r"#(?P<idx>\d+) = (?P<op>\w+) \[ (?P<ins>[^\]]+) \] ((?P<opt>\w+) \[ (?P<arg>[^\]]+) \] )*Output \[ (?P<out>[^\]]+) \]"
    )
    out_indexed_arith_pattern = re.compile(
        r"(#(?P<lhs_idx>\d+)\.(?P<lhs_col>\w+)) (?P<op>[=<>+\-*/]+) (#(?P<rhs_idx>\d+)\.(?P<rhs_col>\w+)) (?P<alias>AS \w+)"
    )
    out_arith_pattern = re.compile(
        r"(?P<lhs>\w+) (?P<op>[=<>+\-*/]+) (?P<rhs>\w+) (?P<alias>AS \w+)"
    )
    out_aliased_pattern = re.compile(
        r"(?P<exp>[\w\(\)]+) (?P<alias>AS \w+)"
    )

    ctes = []
    i2c = {}  # CTE index to CTE name

    def replace_temporal_predicate(qpl: str) -> str:
        temporal_predicate_pattern = re.compile(
            r"(?P<dt1>[\w\.#]+) (?P<op>DURING|MEETS|MET_BY) (?P<interval>(TIME_INTERVAL|TIME_POINT|TIME_POINT_START_OF)\(.+\))"
        )

        def temporal_predicate_replacer(match):
            temp_pred_sub_pattern_1 = re.compile(r"^TIME_INTERVAL\((?P<args>[^']+, '[^']+')\)$")
            temp_pred_sub_pattern_2 = re.compile(r"^TIME_INTERVAL\((?P<args>[^']+, [^']+, [^']+)\)$")
            temp_pred_sub_pattern_3 = re.compile(r"^TIME_INTERVAL\((?P<args>[^']+, [^']+)\)$")                                      # [X]
            temp_pred_sub_pattern_4 = re.compile(r"^TIME_POINT\((?P<args>[^']+, '[^']+')\)$")                                       # [X]
            temp_pred_sub_pattern_5 = re.compile(r"^TIME_POINT\((?P<args>[^']+, [^']+, [^']+, [^']+, [^']+, [^']+)\)$")
            temp_pred_sub_pattern_6 = re.compile(r"^TIME_POINT_START_OF\((?P<args>[^']+, [^']+, [^']+)\)$")
            temp_pred_sub_pattern_7 = re.compile(r"^TIME_POINT\((?P<args>[^']+)\)$")

            gd = match.groupdict()
            dt1 = gd["dt1"]
            temporal_op = gd["op"]
            interval = gd["interval"]

            temp_pred_replaced = "dbo.{temporal_op}({dt1}, dbo.{interval_op}({args})) = 1"

            if m := temp_pred_sub_pattern_1.match(interval):
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op="TIME_INTERVAL_REL", args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_2.match(interval):
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_INTERVAL_YMD', args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_3.match(interval):  # [X]
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_INTERVAL', args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_4.match(interval):  # [X]
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_POINT_REL', args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_5.match(interval):  # [X]
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_POINT_YMDHMS', args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_6.match(interval):
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_POINT_START_OF_YMD', args=m.groupdict()['args'])

            elif m := temp_pred_sub_pattern_7.match(interval):
                return temp_pred_replaced.format(
                    temporal_op=temporal_op, dt1=dt1, interval_op='TIME_POINT', args=m.groupdict()['args'])

            raise ValueError(f"temporal_predicate_replacer: unknown pattern matched, match = [{match.group(0)}]")

        return match_and_replace(qpl, [
            (temporal_predicate_pattern.pattern, temporal_predicate_replacer)
        ])

    def replace_indexed_output_list(_output_list):
        _out_list_rep = []
        for _out in _output_list:
            if _m := out_indexed_arith_pattern.match(_out):
                _g = _m.groupdict()
                lhs_idx = int(_g['lhs_idx'])
                lhs_col = _g['lhs_col']
                _op = _g['op']
                rhs_idx = int(_g['rhs_idx'])
                rhs_col = _g['rhs_col']

                _out_rep = f"{i2c[lhs_idx]}.{lhs_col} "\
                           f"{_op} "\
                           f"{i2c[rhs_idx]}.{rhs_col}"

                if _op not in ['+', '-', '*', '/']:  # (?P<op>[=<>+\-*/]+)
                    _out_rep = f'IIF({_out_rep}, 1, 0)'

                _out_list_rep.append(f"{_out_rep} {_g['alias']}")

            elif _m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", _out):
                _g = _m.groupdict()
                _in_name = i2c[int(_g["i"])]
                _out_list_rep.append(f"{_in_name}.{_g['col']}")

            elif ("_" in _out and
                  (('Min_'      in _out) or
                   ('Max_'      in _out) or
                   ('Count_'    in _out) or
                   ('Sum_'      in _out) or
                   ('Avg_'      in _out) or
                   ('Plus_'     in _out) or
                   ('Minus_'    in _out) or
                   ('Mul_'      in _out) or
                   ('Div_'      in _out) or
                   ('Ls_'       in _out) or
                   ('Gr_'       in _out) or
                   ('Eq_'       in _out) or
                   ('Leq_'      in _out) or
                   ('Geq_'      in _out) or
                   ('Diff_'     in _out) or
                   ('Prod_'     in _out) or
                   ('datediff_' in _out) or
                   ('getdate_'  in _out) or
                   ('format_'   in _out) or
                   ('_rank_'    in _out))
            ):
                # Probably enough to check just if '_' in _out.
                _out_replaced_idx = replace_indexes(_out)
                _out_list_rep.append(_out_replaced_idx)

            elif _out == "1 AS One":
                _out_list_rep.append(_out)

            else:
                raise AssertionError(f"Don't know how to handle {_out = }")

        return _out_list_rep

    def replace_output_list(_output_list):
        _out_list_rep = []
        for _out in _output_list:
            _out_rep = _out
            if _m := out_arith_pattern.match(_out):
                _g = _m.groupdict()
                _out_rep = f"{_g['lhs']} {_g['op']} {_g['rhs']}"
                if _g['op'] not in ['+', '-', '*', '/']:
                    _out_rep = f'IIF({_out_rep}, 1, 0)'
                _out_rep = f"{_out_rep} {_g['alias']}"

            _out_list_rep.append(_out_rep.replace('countstar', 'COUNT(*)'))

        return _out_list_rep

    def replace_indexes(indexed_element: str):
        pred_indexed_pattern = re.compile(
            r"(?P<idx>#\d+)(?P<rest>[\.|_]\w+)"
        )

        def indexed_preficate_replacer(match):
            _gd = match.groupdict()
            idx = int(_gd['idx'][1:])
            return f"{i2c[idx]}{_gd['rest']}"

        return match_and_replace(indexed_element, [
            (pred_indexed_pattern.pattern, indexed_preficate_replacer)
        ])

    for line in flat_qpl:
        if m := flat_qpl_scan_pattern.match(line):
            captures = m.groupdict()
            idx = int(captures["idx"])
            table = f"{db_id}.{captures['table']}"
            distinct = captures["distinct"]
            predicate = replace_temporal_predicate(captures["pred"])
            output_list = re.split(r"\s+, ", captures["out"])
            if predicate:
                cte = CTE(
                    f"Scan_{idx}",
                    f"SELECT{f' DISTINCT' if distinct else ''} {', '.join(output_list)} FROM {table} WHERE {predicate}",
                )
            else:
                cte = CTE(
                    f"Scan_{idx}",
                    f"SELECT{f' DISTINCT' if distinct else ''} {', '.join(output_list)} FROM {table}",
                )
            i2c[idx] = cte.name
            ctes.append(cte)

        elif m := flat_qpl_line_pattern.match(line):
            captures = m.capturesdict()
            idx = int(captures["idx"][0])
            op = captures["op"][0]
            ins = [int(x[1:]) for x in re.split(r"\s+, ", captures["ins"][0])]
            option_names = captures["opt"]
            args = captures["arg"]
            opts = dict(zip(option_names, args))
            output_list = re.split(r"\s+, ", captures["out"][0])

            if op == "Aggregate":
                i = ins[0]
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                group_by = set()
                if gb := opts.get("GroupBy"):
                    group_by.add(gb)

                out_list_replaced = replace_output_list(output_list)
                for out in out_list_replaced:
                    if " as " not in out.lower():  # why is this?
                        group_by.add(out)

                if group_by:
                    cte = CTE(
                        f"Aggregate_{idx}",
                        f"SELECT {distinct}{', '.join(out_list_replaced)} FROM {i2c[i]} GROUP BY {', '.join(group_by)}",
                    )
                else:
                    cte = CTE(
                        f"Aggregate_{idx}",
                        f"SELECT {distinct}{', '.join(out_list_replaced)} FROM {i2c[i]}",
                    )

            elif op == "Except":
                lhs, rhs = ins
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                predicate = replace_temporal_predicate(opts.get("Predicate"))
                if predicate and (
                    m := re.match(
                        r"(#(?P<rhs_table>\d+)\.(?P<rhs_col>\w+)) (=|IS) (#(?P<lhs_table>\d+)\.(?P<lhs_col>\w+))",
                        predicate,
                    )
                ):
                    groups = m.groupdict()
                    lhs_table = int(groups["lhs_table"])
                    rhs_table = int(groups["rhs_table"])
                    predicate_ins = [lhs_table, rhs_table]
                    lhs_pred_col = groups["lhs_col"]
                    rhs_pred_col = groups["rhs_col"]
                    if rhs_table < lhs_table:
                        rhs_table, lhs_table = lhs_table, rhs_table
                        rhs_pred_col, lhs_pred_col = lhs_pred_col, rhs_pred_col
                    assert set(predicate_ins) <= set(
                        ins
                    ), "Except uses columns in predicate that are not direct inputs"
                    replaced_output_list = []
                    for out in output_list:
                        if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                            g = m.groupdict()
                            i = int(g["i"])
                            col = g["col"]
                            replaced_output_list.append(f"{i2c[i]}.{col}")
                        elif out == "1 AS One":
                            replaced_output_list.append(out)
                        else:
                            raise AssertionError(f"Don't know how to handle {out = }")
                    cte = CTE(
                        f"Except_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {lhs_pred_col} NOT IN (SELECT {rhs_pred_col} FROM {i2c[rhs]})",
                    )
                elif predicate and (
                    m := re.match(
                        r"#(?P<rhs_table>\d+)\.(?P<rhs_col>\w+) IS NULL OR #(?P<lhs_table>\d+)\.(?P<lhs_col>\w+) = #\1\.\2",
                        predicate,
                    )
                ):
                    # NOTE: This is how the plan looks like (usually) for a NOT IN query
                    groups = m.groupdict()
                    lhs_pred_col = groups["lhs_col"]
                    rhs_pred_col = groups["rhs_col"]
                    replaced_output_list = []
                    for out in output_list:
                        if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                            g = m.groupdict()
                            i = int(g["i"])
                            col = g["col"]
                            replaced_output_list.append(f"{i2c[i]}.{col}")
                        else:
                            raise AssertionError(f"Don't know how to handle {out = }")
                    cte = CTE(
                        f"Except_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {lhs_pred_col} NOT IN (SELECT {rhs_pred_col} FROM {i2c[rhs]})",
                    )
                elif predicate and (
                    m := re.match(
                        r"#(?P<table>\d+)\.(?P<col>\w+) IS NULL",
                        predicate,
                    )
                ):
                    g = m.groupdict()
                    table = g["table"]
                    col = g["col"]
                    replaced_output_list = []
                    for out in output_list:
                        if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                            g = m.groupdict()
                            i = int(g["i"])
                            c = g["col"]
                            replaced_output_list.append(f"{i2c[i]}.{c}")
                        else:
                            raise AssertionError(f"Don't know how to handle {out = }")
                    cte = CTE(
                        f"Except_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {col} NOT IN (SELECT {col} FROM {i2c[rhs]})",
                    )
                elif except_columns := opts.get("ExceptColumns"):
                    ec = re.sub(r"(#\d+|\w+)\.", "", except_columns)
                    replaced_output_list = []
                    for out in output_list:
                        if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                            g = m.groupdict()
                            i = int(g["i"])
                            c = g["col"]
                            replaced_output_list.append(f"{i2c[i]}.{c}")
                        else:
                            raise AssertionError(f"Don't know how to handle {out = }")
                    cte = CTE(
                        f"Except_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE NOT EXISTS (SELECT {ec} FROM {i2c[rhs]} WHERE {i2c[lhs]}.{ec} = {i2c[rhs]}.{ec})",
                    )
                else:
                    raise AssertionError("Unknown Except variant")

            elif op == "Filter":
                i = ins[0]
                predicate_replaced = replace_temporal_predicate(opts["Predicate"])
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                cte = CTE(
                    f"Filter_{idx}",
                    f"SELECT {distinct}{', '.join(output_list)} FROM {i2c[i]} WHERE {predicate_replaced}",
                )

            elif op == "Intersect":
                lhs, rhs = ins
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                replaced_output_list = replace_indexed_output_list(output_list)
                predicate = replace_temporal_predicate(opts.get("Predicate"))
                if predicate and (
                    m := re.match(
                        r"(#(?P<lhs_table>\d+)\.(?P<lhs_col>\w+)) = (#(?P<rhs_table>\d+)\.(?P<rhs_col>\w+))",
                        predicate,
                    )
                ):
                    groups = m.groupdict()
                    lhs_table = int(groups["lhs_table"])
                    rhs_table = int(groups["rhs_table"])
                    predicate_ins = [lhs_table, rhs_table]
                    lhs_pred_col = groups["lhs_col"]
                    rhs_pred_col = groups["rhs_col"]
                    if rhs_table > lhs_table:
                        rhs_table, lhs_table = lhs_table, rhs_table
                        rhs_pred_col, lhs_pred_col = lhs_pred_col, rhs_pred_col
                    assert set(predicate_ins) <= set(
                        ins
                    ), "Intersect uses columns in predicate that are not direct inputs"

                    cte = CTE(
                        f"Intersect_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {rhs_pred_col} IN (SELECT {lhs_pred_col} FROM {i2c[rhs]})",
                    )
                else:
                    cte = CTE(
                        f"Intersect_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} INTERSECT SELECT {', '.join(replaced_output_list)} FROM {i2c[rhs]}",
                    )

            elif op == "Join":
                lhs, rhs = ins
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                replaced_output_list = replace_indexed_output_list(output_list)
                predicate = opts.get("Predicate")
                if predicate:
                    predicate = replace_temporal_predicate(opts.get("Predicate"))
                    predicate = replace_indexes(predicate)
                    pred_result = [predicate]
                    cte = CTE(
                        f"Join_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} JOIN {i2c[rhs]} ON {' AND '.join(pred_result)}",
                    )

                else:
                    cte = CTE(
                        f"Join_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} CROSS JOIN {i2c[rhs]}",
                    )

            elif op == "Sort":
                i = ins[0]
                order_by = opts["OrderBy"]
                # order_by = f"{order_by}, ROW_NUMBER() OVER (ORDER BY (SELECT 1))" if (order_by is not None) and (order_by != "") else order_by
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                cte = CTE(
                    f"Sort_{idx}",
                    f"SELECT TOP 1000000000 {distinct}{', '.join(output_list)} FROM {i2c[i]} ORDER BY {order_by}",
                )

            elif op == "Top":
                i = ins[0]
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                rows = opts['Rows']
                outs = ', '.join(output_list)
                order_by = f" ORDER BY {opts['OrderBy']}" if opts.get("OrderBy") else ""
                # order_by = f"{order_by}, ROW_NUMBER() OVER (ORDER BY (SELECT 1))" if (order_by is not None) and (order_by != "") else order_by

                if offset := opts.get("Offset"):
                    # order_by = f" ORDER BY (SELECT 1), ROW_NUMBER() OVER (ORDER BY (SELECT 1))" if order_by == "" else order_by
                    order_by = f" ORDER BY (SELECT 1)" if order_by == "" else order_by
                    cte = CTE(
                        f"Top_{idx}",
                        f"SELECT {distinct}{outs} FROM {i2c[i]}{order_by} OFFSET {offset} ROWS FETCH FIRST {rows} ROWS ONLY",
                    )
                else:
                    cte = CTE(
                        f"Top_{idx}",
                        f"SELECT {distinct}TOP {rows} {outs} FROM {i2c[i]}{order_by}",
                    )

            elif op == "TopSort":
                i = ins[0]
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                rows = opts["Rows"]
                outs = ', '.join(output_list)
                order_by = opts["OrderBy"]
                # order_by = f"{order_by}, ROW_NUMBER() OVER (ORDER BY (SELECT 1))" if (order_by is not None) and (order_by != "") else order_by
                with_ties = "WITH TIES " if opts.get("WithTies") else ""

                if offset := opts.get("Offset"):
                    if with_ties == "":
                        cte = CTE(
                            f"TopSort_{idx}",
                            f"SELECT {distinct}{outs} FROM {i2c[i]} ORDER BY {order_by} OFFSET {offset} ROWS FETCH FIRST {rows} ROWS ONLY",
                        )
                    else:
                        print(f"flat_qpl_to_cte: TopSort - With Ties TIES AND Offset! idx=[{idx}], offset=[{offset}]")
                        cte = CTE(
                            f"TopSort_{idx}",
                            f"SELECT {distinct}TOP {rows} {with_ties}{outs} FROM "
                            f"(SELECT {outs} FROM {i2c[i]} ORDER BY {order_by} OFFSET {offset} ROWS) as subqr "
                            f"ORDER BY {order_by}",
                        )
                else:
                    cte = CTE(
                        f"TopSort_{idx}",
                        f"SELECT {distinct}TOP {rows} {with_ties}{outs} FROM {i2c[i]} ORDER BY {order_by}",
                    )

            elif op == "Union":
                lhs, rhs = ins
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                replaced_output_list = []
                for out in output_list:
                    if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                        g = m.groupdict()
                        col = g["col"]
                        replaced_output_list.append(col)
                    elif "_" in out and out[: out.index("_")] in (
                        "Min",
                        "Max",
                        "Count",
                        "Sum",
                        "Avg",
                    ):
                        replaced_output_list.append(out)
                    elif out == "1 AS One":
                        replaced_output_list.append(out)
                    else:
                        raise AssertionError(f"Don't know how to handle {out = }")
                cte = CTE(
                    f"Union_{idx}",
                    f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} UNION SELECT {', '.join(replaced_output_list)} FROM {i2c[rhs]}",
                )

            elif op == "SequenceProject":
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                in_name = i2c[ins[0]]
                over = opts["Over"]

                out_list_rep = []
                for out in output_list:
                    out_rep = out
                    if m := out_aliased_pattern.match(out):
                        gd = m.groupdict()
                        if gd['exp'] in ['dense_rank()', 'percent_rank()']:
                            out_rep = f"{gd['exp'].upper()} OVER (ORDER BY {over}) {gd['alias']}"

                    out_list_rep.append(out_rep)

                cte = CTE(
                    f"SequenceProject_{idx}",
                    f"SELECT {distinct}{', '.join(out_list_rep)} FROM {in_name}",
                )

            else:
                raise ValueError(f"Unrecognized op: {op}")

            i2c[idx] = cte.name
            ctes.append(cte)
        else:
            raise ValueError(f"Invalid Flat QPL Line: {line = }")

    if ctes[-1].name.startswith("Sort"):
        return "WITH {ctes} {sort_query}".format(
            ctes=", ".join([f"{cte.name} AS ( {cte.query} )" for cte in ctes[:-1]]),
            sort_query=ctes[-1].query,
        )
    return "WITH {ctes} SELECT * FROM {last}".format(
        ctes=", ".join([f"{cte.name} AS ( {cte.query} )" for cte in ctes]),
        last=ctes[-1].name,
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open("./manual-cte.json") as f:
        manual_ctes = {ex["id"]: ex["cte"] for ex in json.load(f)}

    with open(args.input) as f:
        qpls = json.load(f)

    with_cte = []
    for ex in qpls:
        if ex["id"] in manual_ctes:
            ex["cte"] = manual_ctes[ex["id"]]
            with_cte.append(ex)
            continue
        if "valid" in ex and not ex["valid"]:
            ex["cte"] = None
            with_cte.append(ex)
            continue
        db_id, qpl = ex["qpl"].split(" | ")
        try:
            result = flat_qpl_to_cte(qpl.split(" ; "), db_id)
        except Exception as e:
            print(f"Error in id {ex['id']}: {e}")
        else:
            ex["cte"] = result
            with_cte.append(ex)

    with open(args.output, "w") as f:
        json.dump(with_cte, f, indent=2)


if __name__ == "__main__":
    main()
