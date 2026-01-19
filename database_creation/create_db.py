import argparse
import json
import sqlite3
import subprocess
from pathlib import Path
from typing import List

import numpy as np
import pandas as pd
import pymssql
import sqlalchemy
from sqlalchemy import create_engine
from tqdm.auto import tqdm


def create_database(dbs: List[Path]):
    conn = pymssql.connect("0.0.0.0", "SA", "Passw0rd!", autocommit=True)
    cursor = conn.cursor()
    cursor.execute("CREATE DATABASE spider")
    cursor.execute("USE spider")
    for db in dbs:
        cursor.execute(f"CREATE SCHEMA {db.stem}")
    conn.close()
    ddls = Path("./schemas").glob("**/*.sql")
    for ddl in ddls:
        subprocess.run(
            [
                "/opt/mssql-tools/bin/sqlcmd",
                "-U",
                "SA",
                "-P",
                "Passw0rd!",
                "-i",
                str(ddl),
            ]
        )


def get_tables(cursor):
    return [
        x[0].lower()
        for x in cursor.execute(
            "SELECT name FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%'"
        ).fetchall()
    ]


def get_types(cursor, table):
    result = cursor.execute(f"SELECT * FROM pragma_table_info('{table}')").fetchall()
    return {x[1]: x[2] for x in result}


def convert_sqlite_type(schema, df, types):
    def try_(f):
        def g(x):
            if x == "inf":
                return np.nan
            try:
                return f(x)
            except:
                return np.nan

        return g

    for col, type_ in types.items():
        t = type_.lower()
        cl = col.lower()
        if t.startswith("int") or t.startswith("bigint") or "unsigned" in t:
            df[col] = df[col].apply(try_(int))
        elif (
            t.startswith("numeric")
            or t.startswith("float")
            or t.startswith("real")
            or t.startswith("double")
            or t.startswith("decimal")
        ):
            df[col] = df[col].apply(try_(float))
        elif schema == "car_1" and cl in ("horsepower", "mpg"):
            if cl == "horsepower":
                df[col] = df[col].apply(try_(int))
            else:
                df[col] = df[col].apply(try_(float))
        elif (
            schema == "student_transcripts_tracking"
            and cl == "transcript_date"
            and t == "datetime"
        ):
            df[col] = pd.to_datetime(df[col]).dt.year
        elif schema == "wta_1" and t == "date":
            df[col] = pd.to_datetime(df[col], format="%Y%m%d")
        else:  # keep other types as text
            pass

    return df


def dump(schema, conn, cursor):
    tables = get_tables(cursor)
    result = {}
    for t in tables:
        types = get_types(cursor, t)
        df = pd.read_sql(f"select * from {t}", conn)
        if schema == "orchestra" and t == "show":
            df.rename(
                {"If_first_show": "Result", "Result": "If_first_show"},
                axis=1,
                inplace=True,
            )
        result[t] = convert_sqlite_type(schema, df, types)
    return result


def dump_all(dbs: List[Path]):
    result = {}
    for db in dbs:
        conn = sqlite3.connect(db)
        conn.text_factory = lambda b: b.decode(errors="ignore")
        cursor = conn.cursor()
        schema = db.stem
        result[schema] = dump(schema, conn, cursor)
    return result


def fill_databases():
    conn = pymssql.connect("0.0.0.0", "SA", "Passw0rd!", autocommit=True)
    cursor = conn.cursor()
    cursor.execute("USE spider")
    df = pd.read_pickle("./data_to_insert_no_alters.pkl")
    for _, row in tqdm(list(df.iterrows())):
        try:
            cursor.execute(row["sql"], row["parameters"])
        except:
            pass


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--spider-path", type=Path)
    args = parser.parse_args()
    spider_path: Path = args.spider_path

    dbs = list((spider_path / "database").glob("**/*.sqlite"))

    create_database(dbs)

    data = dump_all(dbs)

    engine = create_engine(
        "mssql+pyodbc://SA:Passw0rd!@0.0.0.0/spider?driver=ODBC+Driver+17+for+SQL+Server",
    )
    sorted_tables_by_schema = json.load(open("./tables-sorted.json"))
    for schema, table_data in (bar := tqdm(data.items())):
        bar.set_description(schema)
        for table_name in sorted_tables_by_schema[schema]:
            try:
                rows = table_data.get(table_name)
                if rows is not None:
                    rows.to_sql(
                        table_name,
                        engine,
                        schema=schema,
                        if_exists="append",
                        index=False,
                        chunksize=1,
                    )
            except sqlalchemy.exc.IntegrityError:
                pass

    engine.dispose()

    fill_databases()


if __name__ == "__main__":
    main()
