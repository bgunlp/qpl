from collections import Counter

import numpy as np
import pandas as pd


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


# Comparisons with Floats are not deterministic
# Encode Floats as Strings.
def encode_dict(d):
    for k in d.keys():
        if type(d[k]) == type(1.01):
            d[k] = str(d[k])
    return frozenset(d.items())


# Given a list of keys - return a string with the value of the keys with ":::" separator
def get_keys(d, keys):
    return ":::".join(str(d[k]) for k in keys)


# If last statement in qpl is a SORT operator - return the list of order_by keys else None
# For example: "... #8 = Sort [ #7 ] OrderBy [ Model ASC ] Distinct [ true ] Output [ Model ]" -> [ 'Model' ]
# OrderBy values can be: [ {<field> [ASC|DESC]?}+ ]
def get_order_by(qpl):
    last_qpl = qpl[-1].split(" ")
    last_qpl_op = last_qpl[2].lower()
    if last_qpl_op != "sort":
        return None
    keys = []
    i = last_qpl.index("OrderBy") + 2  # First position after OrderBy [
    while last_qpl[i] != "]":
        keys.append(last_qpl[i].lower())
        i += 1
        if last_qpl[i].lower() in ["asc", "desc"]:
            i += 1
        if last_qpl[i] == ",":
            i += 1
    return keys


# rs1 is gold resultset
# rs2 is predicted (or computed) resultset
# order_by is a list of keys to sort by
def eq_resultset(rs1, rs2, order_by):
    list1 = [encode_dict(d) for d in rs1]
    list2 = [encode_dict(d) for d in rs2]

    counter1 = Counter(list1)
    counter2 = Counter(list2)

    if counter1 != counter2:
        return False

    if not order_by:
        return True

    # If the sorting keys of the QPL are present in the gold resultset
    order_by_intersect = frozenset(order_by).intersection(rs_columns(rs1))

    # Verify that the order_by projection is properly sorted in predicted
    # This covers the case when the order_by keys includes duplicated values
    # in which case the order by is not fully deterministic
    ordered_keys_1 = [get_keys(d, order_by_intersect) for d in rs1]
    ordered_keys_2 = [get_keys(d, order_by_intersect) for d in rs2]
    return ordered_keys_1 == ordered_keys_2


# grs: gold result set returned by original SQL (resultset is a list of dicts)
# prs: result set either predicted by model or computed by QPL/CTE transformation
# qpl: list of strings - qpl sequence
# - If order_by is NONE:
#      Check set equality (ignore order of rows)
# - Else if same order of rows - return TRUE
# - Else (Not same row order):
#     sorting keys are present in sql and in qpl - Check order for the sorting keys
#     sorting keys are not present in sql - Check set equality (ignore order of rows)
def same_rs(grs, prs, qpl):
    # Geţ the orderBy list of fields in the QPL
    order_by = get_order_by(qpl)

    # Same number of rows
    if len(grs) == 0 and len(prs) == 0:
        return True

    if len(grs) == 0 or len(prs) == 0:
        return False

    # Same number of columns
    if len(grs[0]) == len(prs[0]):
        gdf = pd.DataFrame(grs)
        pdf = pd.DataFrame(prs)
        if np.array_equal(gdf.to_numpy(), pdf.to_numpy()):
            return True

    # good_keys_prs is a resultset that only includes the keys from prs that are aligned with a key in grs
    # The keys appear under the name of the grs with the value from prs for the corresponding key.
    good_keys_prs = rs_good_keys_fuzzy(grs, prs)

    return eq_resultset(grs, good_keys_prs, order_by)
