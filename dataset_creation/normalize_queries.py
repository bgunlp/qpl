import argparse
import json
from pathlib import Path

import regex as re


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open(args.input) as f:
        qpls = json.load(f)

    result = []
    for ex in qpls:
        query = ex["query"]
        query = re.sub(r"OPTION \(.*\)", "", query)
        query = re.sub(r"WITH \(FORCESCAN\)", "", query)
        ex["clean_query"] = query.strip()
        ex["prefixed_qpl"] = ex["qpl"]
        db_id, qpl = ex["qpl"].split(" | ")
        ex["db_id"] = db_id
        ex["qpl"] = qpl
        result.append(ex)

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)


if __name__ == "__main__":
    main()
