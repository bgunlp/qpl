import argparse
import json
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine


def get_results(q, engine):
    try:
        df = pd.read_sql(q, engine)
        df.columns = df.columns.str.lower()
        return df.to_dict(orient="records")
    except:
        return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open(args.input) as f:
        qpls = json.load(f)

    engine = create_engine(
        "mssql+pyodbc://SA:Passw0rd!@0.0.0.0/spider?driver=ODBC+Driver+17+for+SQL+Server"
    )

    result = []
    for ex in qpls:
        ex["crs"] = get_results(ex["cte"], engine)
        ex["grs"] = get_results(ex["query"], engine)
        result.append(ex)

    pd.DataFrame(result).to_pickle(args.output)


if __name__ == "__main__":
    main()
