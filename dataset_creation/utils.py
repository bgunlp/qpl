import copy
import re

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
