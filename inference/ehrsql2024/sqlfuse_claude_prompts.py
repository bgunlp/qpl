import json


def sqlfuse_generate_schema_info_string(sqlfuse_schema_info_filepath='sqlfuse_schema_info.json', db_id='mimic_iv') -> str:
    with open(sqlfuse_schema_info_filepath, "r") as file:
        all_schemas_info = json.load(file)

    schema_info = all_schemas_info[db_id]
    schema_info_str = ""

    for table_name, table_info in schema_info.items():
        # schema_info_str += f"Table {table_name}, columns = {[c.name for c in table_info.columns]}, primary_keys = {table_info.primary_keys}\n"
        schema_info_str += f"{table_name}, columns = "
        columns_str_list = []
        for column in table_info['columns']:
            if (
                len(column['enum_values']) > 0 and column['display_enum_values_on_prompt']
            ):  # Display the enum values if they are available and the column is marked to display them
                column_enums = [
                    (f"{enum['enum_value']}->{enum['translation']}" if enum['translation'] else enum['enum_value'])
                    for enum in column['enum_values']
                ]
                columns_str_list.append(f"{column['name']}(Enums:{','.join(column_enums)})")
            else:  # Display only the column name
                columns_str_list.append(column['name'])

        schema_info_str += f"[{','.join(columns_str_list)}], primary_keys = {table_info['primary_keys']}\n"

        if len(table_info['foreign_keys']) > 0:
            foreign_keys_list = []
            for fk in table_info['foreign_keys']:
                # Look for the relationship type
                fk_string = f"{fk['current_table']}.{fk['current_column']}={fk['outer_table']}.{fk['outer_column']}"
                if fk['relationship'] is not None:
                    if (
                        "N" == fk['relationship'][0]
                    ):  # N:1 or N:N. Switch the tables so that the relationship is always 1:N or 1:1 or N:N
                        fk_string = f"{fk['outer_table']}.{fk['outer_column']}={fk['current_table']}.{fk['current_column']} ({fk['relationship'][::-1]})"
                    else:
                        fk_string = (
                            f"{fk['current_table']}.{fk['current_column']}={fk['outer_table']}.{fk['outer_column']} ({fk['relationship']})"
                        )
                foreign_keys_list.append(fk_string)
            schema_info_str += f"Foreign_keys = {foreign_keys_list}"

    return schema_info_str


def sqlfuse_generate_schema_linking_prompt(schema_info_str, question):
    return SQLFUSE_SCHEMA_LINKING_PROMPT_USER.format(
        schema_description=schema_info_str,
        question=question,
    )


SQLFUSE_SCHEMA_LINKING_PROMPT_SYSTEM = """
You will recieve an SQL schema.
Your job is to find schema_links and other important features about the schema.
Your respond should be in the following JSON format:
{
    columns: <The required columns to answer the question. Show your chain of thoughts.>,
    foreign_keys: <The required foreign keys to answer the question. Show your chain of thoughts.>,
    schema_links: <The required schema links to answer the question>
}
"""

SQLFUSE_SCHEMA_LINKING_PROMPT_USER = """
# Find the schema_links for generating SQL queries for each question based on the database schema and Foreign keys.
{schema_description}
Question: {question}
"""

SQLFUSE_SCHEMA_LINKING_PROMPT_FS_EXAMPLE_INPUT = """
# Find the schema_links for generating SQL queries for each question based on the database schema and Foreign keys.
Table conductor, columns = [Conductor_ID, Name, Age, Nationality(Enums: USA, UK, France), Year_of_Work], primiry_keys = [Conductor_ID] 
Table orchestra, columns = [Orchestra_ID, Orchestra, Conductor_ID, Record_Company, Year_of_Founded, Major_Record_Format(Enums: CD,DVD)], primiry_keys = [Orchestra_ID]
Table performance, columns = [Performance_ID, Orchestra_ID, Type,Date, Official ratings_(millions), Weekly_rank,Share], primiry_keys = [Performance_ID]
Table show, columns = [Show_ID, Performance_ID, If_first_show, Result(Enums T->True, F->False),Attendance], primiry_keys = []
Foreign_keys = [orchestra.Conductor_ID=conductor.Conductor_ID (IN), performance.Orchestra_ID=orchestra.Orchestra_ID (1:1), show.Performance_ID=performance.Performance_ID (1:1)]
Question: Show the names of conductors that have conducted more than one orchestras.
"""

SQLFUSE_SCHEMA_LINKING_PROMPT_FS_EXAMPLE_OUTPUT = """
{
    "columns": ["'the names of conductors' so we need column = [conductor.Name]", "'that have conducted more than one orchestras' so we need column = [lorchestra.Conductor_ID]"],
    "foreign_keys": "Based on the columns and tables, we need these Foreign_keys - [orchestra.Conductor_ID = conductor.Conductor_ID]",
    "schema_links": ["conductor.Name","orchestra.Conductor_ID = conductor.Conductor_ID"]
}
"""

def main():
    schema_info_str = sqlfuse_generate_schema_info_string()
    question = "Show the names of conductors that have conducted more than one orchestras."
    schema_linking_prompt = sqlfuse_generate_schema_linking_prompt(schema_info_str, question)
    print(f"Schema Linking Prompt:\n{schema_linking_prompt}")


if __name__ == "__main__":
    main()
