import copy
import re

QPL_KEYWORDS_SINGLE = {
    "scan",
    "aggregate",
    "filter",
    "sort",
    "top",
    "join",
    "intersect",
    "except",
    "union",
    "predicate",
    "distinct",
    "rows",
    "output",
    "table",
}

QPL_KEYWORDS_MULTI = {
    "topsort": "TopSort",
    "orderby": "OrderBy",
    "groupby": "GroupBy",
    "withties": "WithTies",
    "exceptcolumns": "ExceptColumns",
}


def token_postprocess(qpl: str) -> str:
    # Replace special tokens
    qpl = (
        qpl.replace(" average (", " avg (")
        .replace(" descending ", " desc ")
        .replace(" ascending ", " asc ")
        .replace(" 1 as one ", " 1 AS One ")
    )
    for kw, repl in QPL_KEYWORDS_MULTI.items():
        qpl = qpl.replace(f" {kw} ", f" {repl} ")
    for kw in QPL_KEYWORDS_SINGLE:
        qpl = qpl.replace(f" {kw} ", f" {kw.title()} ")
    # Remove spaces between underscores
    qpl = qpl.replace(" _ ", "_")
    # Remove spaces between line number and column name
    qpl = re.sub(r"(#\d+) ?\. (\w+)", r"\1.\2", qpl)
    return qpl


pat = re.compile(r"(?<=\w)_(?=\w)")


def schema_preprocess(schema):
    new_schema = copy.deepcopy(schema)
    new_schema["table_names"] = [
        pat.sub(" _ ", tn).lower() for tn in schema["table_names"]
    ]
    new_schema["column_names"] = [
        pat.sub(" _ ", cn).lower() for cn in schema["column_names"]
    ]
    new_schema["table_to_columns"] = {
        pat.sub(" _ ", k): v for k, v in schema["table_to_columns"].items()
    }
    return new_schema
