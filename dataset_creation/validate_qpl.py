import argparse
import json
from pathlib import Path

import pandas as pd
import requests


def eq_aggregated_cols(s1, s2):
    "Determines whether two aggregated column names are equivalent - based on prefix only - case insensitive"
    prefixes = ["count_", "min_", "max_", "avg_", "sum_"]
    s1_lower = s1.lower()
    s2_lower = s2.lower()
    for prefix in prefixes:
        if s1_lower.startswith(prefix) and s2_lower.startswith(prefix):
            return True
    return s1_lower == s2_lower


# Find the matching key for pcol in gcols
# pcol is the name of a column in computed resultset
# gcols are the name of the columns in the gold resultset
# prow and grow are the dict col:val from computed and gold resultset
# The matching is on name of the column - except for aggregated keys agg_suff
# For these aggregated values, the matching is based on the value in the dict
# Example:
# custom_in("k1", ["k1", "k2"], .., ..) -> "k1" (Exact match)
# custom_in("avg_x", ["avg_a", "k2"], .., ..) -> "avg_a" (By prefix)
# custom_in("avg_x", ["avg_a", "avg_b"], {"avg_x": 1, "avg_y": 2}, {"avg_a": 2, "avg_b": 1}) -> "avg_b" (By val)
# custom_in("k1", ["a", "b"], .., ..) -> None (No match)
# custom_in("avg_x", ["avg_a"], {"avg_x": 1}, {"avg_a": 2}) -> "avg_a" (By prefix - no value match and no distractor)
# custom_in("avg_x", ["avg_a", "avg_b"], {"avg_x": 1, "avg_y": 2}, {"avg_a": 3, "avg_b": 4}) -> "avg_a" (By pos)
# custom_in("avg_y", ["avg_a", "avg_b"], {"avg_x": 1, "avg_y": 2}, {"avg_a": 3, "avg_b": 4}) -> "avg_b" (By pos)
def custom_in(pcol, gcols, prow, grow):
    candidates = []
    for c in gcols:
        if eq_aggregated_cols(c, pcol):
            candidates.append(c)
    if candidates == []:
        return False
    elif len(candidates) == 1:
        return candidates[0]
    else:
        # Must choose one of multiple candidates
        # First try the gcol that has the same value in grow as pcol has in prow
        pval = prow[pcol]
        for c in candidates:
            if grow[c] == pval:
                return c
        # Else based on index within the row
        pidx = list(prow.keys()).index(pcol)
        for c in candidates:
            if list(grow.keys()).index(c) == pidx:
                return c
    return False


def rs_columns(rs):
    if len(rs) == 0:
        return set()
    else:
        return frozenset(rs[0].keys())


def rs_good_keys_fuzzy(grs, prs):
    gcolumns = rs_columns(grs)
    pcolumns = rs_columns(prs)
    good_rs = []
    for prow, grow in zip(prs, grs):
        good_keys = {}
        for pkey in pcolumns:
            mkey = custom_in(pkey, gcolumns, prow, grow)
            if mkey:
                good_keys[mkey] = prow[pkey]
        good_rs.append(good_keys)
    return good_rs


def eq_resultset(rs1, rs2, with_order=True):
    if with_order:
        set1 = [frozenset(d.items()) for d in rs1]
        set2 = [frozenset(d.items()) for d in rs2]
    else:
        set1 = {frozenset(d.items()) for d in rs1}
        set2 = {frozenset(d.items()) for d in rs2}
    return set1 == set2


# grs: gold result set returned by original SQL (resultset is a list of dicts)
# prs: result set either predicted by model or computed by QPL/CTE transformation
# qpl: list of strings - qpl sequence
def same_rs(grs, prs, qpl):
    with_order = qpl[-1].lower().split(" ")[2].startswith("sort")
    good_keys = rs_good_keys_fuzzy(grs, prs)
    return eq_resultset(grs, good_keys, with_order)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open("./schemas.json") as f:
        schemas = json.load(f)

    for schema in schemas:
        requests.post("http://localhost:8081/schema", json=schema)

    # with open(args.input) as f:
    #     qpls = json.load(f)
    qpls = pd.read_pickle(args.input).to_dict(orient="records")

    result = []
    for ex in qpls:
        is_valid = requests.post(
            "http://localhost:8081/validate", json={"qpl": ex["qpl"]}
        ).json()
        if (
            ex["crs"]
            and ex["grs"]
            and is_valid
            and same_rs(ex["grs"], ex["crs"], ex["qpl"].split(" ; "))
        ):
            del ex["crs"]
            del ex["grs"]
            result.append(ex)

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)


if __name__ == "__main__":
    main()
