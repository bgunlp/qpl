import argparse
import json
from collections import defaultdict
from pathlib import Path

from tqdm.auto import tqdm

from bridge_content_encoder import get_database_matches


def add_content(db_schemas, ds):
    content = {}

    for sample in tqdm(ds):
        db_id = sample["db_id"]
        question = sample["question"]
        schema = db_schemas[db_id]

        matches = defaultdict(dict)
        for table, columns in schema["tables"].items():
            for column in columns:
                column_name = column[0]
                database_matches = get_database_matches(
                    question, table, column_name, db_id
                )
                if database_matches:
                    matches[table][column_name] = database_matches

        content[sample["id"]] = {
            "db_id": db_id,
            "question": question,
            "db_content": matches,
        }

    return content


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("output", type=Path)

    with open("./db_schemas.json") as f:
        db_schemas = json.load(f)

    args = parser.parse_args()

    with open(args.input_dir / "train.json") as f:
        train = json.load(f)

    with open(args.input_dir / "dev.json") as f:
        dev = json.load(f)

    content = add_content(db_schemas, train + dev)

    with open(args.output, "w") as f:
        json.dump(content, f, indent=2)
