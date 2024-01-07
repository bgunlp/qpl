import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import List

import regex as re


@dataclass
class CTE:
    name: str
    query: str


def flat_qpl_to_cte(flat_qpl: List[str], db_id: str) -> str:
    flat_qpl_scan_pattern = re.compile(
        r"#(?P<idx>\d+) = Scan Table \[ (?P<table>\w+) \]( Predicate \[ (?P<pred>[^\]]+) \])?( Distinct \[ (?P<distinct>true) \])? Output \[ (?P<out>[^\]]+) \]"
    )
    flat_qpl_line_pattern = re.compile(
        r"#(?P<idx>\d+) = (?P<op>\w+) \[ (?P<ins>[^\]]+) \] ((?P<opt>\w+) \[ (?P<arg>[^\]]+) \] )*Output \[ (?P<out>[^\]]+) \]"
    )

    ctes = []
    i2c = {}
    for line in flat_qpl:
        if m := flat_qpl_scan_pattern.match(line):
            captures = m.groupdict()
            idx = int(captures["idx"])
            table = f"{db_id}.{captures['table']}"
            distinct = captures["distinct"]
            predicate = captures["pred"]
            output_list = re.split(r"\s*, ", captures["out"])
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
            ins = [int(x[1:]) for x in re.split(r"\s*, ", captures["ins"][0])]
            option_names = captures["opt"]
            args = captures["arg"]
            opts = dict(zip(option_names, args))
            output_list = re.split(r"\s*, ", captures["out"][0])

            if op == "Aggregate":
                i = ins[0]
                group_by = opts.get("GroupBy")
                group_by = set()
                if gb := opts.get("GroupBy"):
                    group_by.add(gb)
                output_list = [
                    f"COUNT(*) AS Count_Star" if out.startswith("countstar") else out
                    for out in output_list
                ]
                for out in output_list:
                    if " as " not in out.lower():
                        group_by.add(out)
                if group_by:
                    # for g in gb.split(",")[::-1]:
                    #     g = g.strip()
                    #     if g not in output_list:
                    #         output_list = [g] + output_list
                    cte = CTE(
                        f"Aggregate_{idx}",
                        f"SELECT {', '.join(output_list)} FROM {i2c[i]} GROUP BY {', '.join(group_by)}",
                    )
                else:
                    cte = CTE(
                        f"Aggregate_{idx}",
                        f"SELECT {', '.join(output_list)} FROM {i2c[i]}",
                    )
            elif op == "Except":
                lhs, rhs = ins
                predicate = opts.get("Predicate")
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
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {lhs_pred_col} NOT IN (SELECT {rhs_pred_col} FROM {i2c[rhs]})",
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
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {lhs_pred_col} NOT IN (SELECT {rhs_pred_col} FROM {i2c[rhs]})",
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
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {col} NOT IN (SELECT {col} FROM {i2c[rhs]})",
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
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE NOT EXISTS (SELECT {ec} FROM {i2c[rhs]} WHERE {i2c[lhs]}.{ec} = {i2c[rhs]}.{ec})",
                    )
                else:
                    raise AssertionError("Unknown Except variant")
            elif op == "Filter":
                i = ins[0]
                predicate = opts["Predicate"]
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                cte = CTE(
                    f"Filter_{idx}",
                    f"SELECT {distinct}{', '.join(output_list)} FROM {i2c[i]} WHERE {predicate}",
                )
            elif op == "Intersect":
                lhs, rhs = ins
                predicate = opts.get("Predicate")
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
                        f"Intersect_{idx}",
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} WHERE {rhs_pred_col} IN (SELECT {lhs_pred_col} FROM {i2c[rhs]})",
                    )
                else:
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
                        f"Intersect_{idx}",
                        f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} INTERSECT SELECT {', '.join(replaced_output_list)} FROM {i2c[rhs]}",
                    )
            elif op == "Join":
                lhs, rhs = ins
                predicate = opts.get("Predicate")
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                if predicate:
                    pred_pat = r"(#(?P<lhs_table>\d+)\.(?P<lhs_col>\w+)) (?P<op>(<|<=|>|>=|=)) (#(?P<rhs_table>\d+)\.(?P<rhs_col>\w+))"
                    if m := re.match(f"({pred_pat})( AND {pred_pat})*", predicate):
                        captures = m.capturesdict()
                        n = len(next(iter(captures.values())))
                        pred_components = [
                            {key: captures[key][i] for key in captures}
                            for i in range(n)
                        ]
                        pred_result = []
                        for groups in pred_components:
                            pred_op = groups["op"]
                            predicate_ins = [
                                int(i)
                                for i in (groups["lhs_table"], groups["rhs_table"])
                            ]
                            lhs_pred_col = groups["lhs_col"]
                            rhs_pred_col = groups["rhs_col"]
                            assert set(predicate_ins) <= set(
                                ins
                            ), "Join uses columns in predicate that are not direct inputs"
                            pred_result.append(
                                f"{i2c[predicate_ins[0]]}.{lhs_pred_col} = {i2c[predicate_ins[1]]}.{rhs_pred_col}"
                            )
                        replaced_output_list = []
                        for out in output_list:
                            if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                                g = m.groupdict()
                                i = int(g["i"])
                                col = g["col"]
                                replaced_output_list.append(f"{i2c[i]}.{col}")
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
                                raise AssertionError(
                                    f"Don't know how to handle {out = }"
                                )
                        if pred_op == "=":
                            cte = CTE(
                                f"Join_{idx}",
                                f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} JOIN {i2c[rhs]} ON {' AND '.join(pred_result)}",
                            )
                        else:
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
                                    raise AssertionError(
                                        f"Don't know how to handle {out = }"
                                    )
                            cte = CTE(
                                f"Join_{idx}",
                                f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} CROSS JOIN {i2c[rhs]} WHERE {i2c[rhs]}.{lhs_pred_col} {pred_op} {i2c[lhs]}.{rhs_pred_col}",
                            )
                else:
                    replaced_output_list = []
                    for out in output_list:
                        if m := re.match(r"#(?P<i>\d+)\.(?P<col>\w+)", out):
                            g = m.groupdict()
                            i = int(g["i"])
                            col = g["col"]
                            replaced_output_list.append(f"{i2c[i]}.{col}")
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
                        f"Join_{idx}",
                        f"SELECT {distinct}{', '.join(replaced_output_list)} FROM {i2c[lhs]} CROSS JOIN {i2c[rhs]}",
                    )
            elif op == "Sort":
                i = ins[0]
                order_by = opts["OrderBy"]
                distinct = "DISTINCT " if opts.get("Distinct") else ""
                cte = CTE(
                    f"Sort_{idx}",
                    f"SELECT {distinct}{', '.join(output_list)} FROM {i2c[i]} ORDER BY {order_by}",
                )
            elif op == "Top":
                i = ins[0]
                order_by = f" ORDER BY {opts['OrderBy']}" if opts.get("OrderBy") else ""
                cte = CTE(
                    f"Top_{idx}",
                    f"SELECT TOP {opts['Rows']} {', '.join(output_list)} FROM {i2c[i]}{order_by}",
                )
            elif op == "TopSort":
                i = ins[0]
                rows = opts["Rows"]
                order_by = opts["OrderBy"]
                with_ties = "WITH TIES " if opts.get("WithTies") else ""
                cte = CTE(
                    f"TopSort_{idx}",
                    f"SELECT TOP {rows} {with_ties}{', '.join(output_list)} FROM {i2c[i]} ORDER BY {order_by}",
                )
            elif op == "Union":
                lhs, rhs = ins
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
                    f"SELECT {', '.join(replaced_output_list)} FROM {i2c[lhs]} UNION SELECT {', '.join(replaced_output_list)} FROM {i2c[rhs]}",
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
