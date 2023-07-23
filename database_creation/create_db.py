import json
import pickle
import sqlite3
import subprocess
from pathlib import Path

import numpy as np
import pandas as pd
import pymssql
import sqlalchemy
from sqlalchemy import create_engine
from tqdm.auto import tqdm

DBS = list(Path("spider/database/").glob("**/*.sqlite"))


def create_database():
    conn = pymssql.connect("0.0.0.0", "SA", "Passw0rd!", autocommit=True)
    cursor = conn.cursor()
    cursor.execute("CREATE DATABASE spider")
    cursor.execute("USE spider")
    for db in DBS:
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


def convert_sqlite_type(df, types):
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
        elif cl in (
            "horsepower",
            "mpg",
        ):  # special case for car_1 schema
            if cl == "horsepower":
                df[col] = df[col].apply(try_(int))
            else:
                df[col] = df[col].apply(try_(float))
        elif (
            cl == "transcript_date" and t == "datetime"
        ):  # special case for `students_transcripts_tracking`
            df[col] = pd.to_datetime(df[col]).dt.year
        else:  # keep other types as text
            pass

    return df


def dump(conn, cursor):
    tables = get_tables(cursor)
    result = {}
    for t in tables:
        types = get_types(cursor, t)
        df = pd.read_sql(f"select * from {t}", conn)
        result[t] = convert_sqlite_type(df, types)
    return result


def dump_all():
    result = {}
    for db in DBS:
        conn = sqlite3.connect(db)
        conn.text_factory = lambda b: b.decode(errors="ignore")
        cursor = conn.cursor()
        result[db.stem] = dump(conn, cursor)
    return result


def fill_databases():
    conn = pymssql.connect("0.0.0.0", "SA", "Passw0rd!", autocommit=True)
    cursor = conn.cursor()
    cursor.execute("USE spider")
    with open("./data_to_insert_no_alters.pkl", "rb") as f:
        data = pickle.load(f)
    for stmt in tqdm(data):
        try:
            cursor.execute(stmt["sql"], stmt["parameters"])
        except:
            pass


if __name__ == "__main__":
    create_database()

    data = dump_all()

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
