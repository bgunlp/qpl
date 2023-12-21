import json
from collections import defaultdict

with open("db_schemas.json") as f:
    db_schemas = json.load(f)


def update_type(col_type):
    if "char" in col_type or col_type == "" or "text" in col_type or "var" in col_type:
        return "text"
    elif (
        "int" in col_type
        or "numeric" in col_type
        or "decimal" in col_type
        or "number" in col_type
        or "id" in col_type
        or "real" in col_type
        or "double" in col_type
        or "float" in col_type
    ):
        return "number"
    elif "date" in col_type or "time" in col_type:
        return "time"
    elif "boolean" in col_type or col_type == "bit":
        return "boolean"
    else:
        return "others"


def get_schema(db_id):
    tables = db_schemas[db_id]["tables"]
    pk = db_schemas[db_id]["pk"]
    fk = db_schemas[db_id].get("fk")

    table_names = []
    column_names = []
    column_types = []
    column_to_table = []
    table_to_columns = defaultdict(list)
    foreign_keys = []
    primary_keys = []

    col_idx = 0

    for table_idx, (table_name, columns) in enumerate(tables.items()):
        table_names.append(table_name)

        for column in columns:
            column_names.append(column[0])
            column_types.append(update_type(column[1]))
            column_to_table.append(table_idx)
            table_to_columns[table_name].append(col_idx)

            if table_name in pk and column[0] in pk[table_name]:
                primary_keys.append(col_idx)

            col_idx += 1

    if fk:
        for fk_table_name, referenced_tables_keys in fk.items():
            for referenced_table_name, all_keys in referenced_tables_keys.items():
                for keys in all_keys:
                    start_col_idx_fk_table = table_to_columns[fk_table_name][0]
                    end_col_idx_fk_table = table_to_columns[fk_table_name][-1]

                    start_col_idx_referenced_table = table_to_columns[
                        referenced_table_name
                    ][0]
                    end_col_idx_referenced_table = table_to_columns[
                        referenced_table_name
                    ][-1]

                    fk_col_idx = start_col_idx_fk_table + column_names[
                        start_col_idx_fk_table : end_col_idx_fk_table + 1
                    ].index(keys[0])
                    referenced_col_idx = start_col_idx_referenced_table + column_names[
                        start_col_idx_referenced_table : end_col_idx_referenced_table
                        + 1
                    ].index(keys[1])

                    foreign_keys.append((fk_col_idx, referenced_col_idx))

    return {
        "db_id": db_id,
        "table_names": table_names,
        "column_names": column_names,
        "column_types": column_types,
        "column_to_table": column_to_table,
        "table_to_columns": table_to_columns,
        "foreign_keys": foreign_keys,
        "primary_keys": primary_keys,
    }


schemas = []
for db_id in db_schemas:
    schema = get_schema(db_id)
    schemas.append(schema)
with open("schemas.json", "w") as f:
    json.dump(schemas, f, indent=2)
