import argparse
import json
from pathlib import Path

import requests


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open("./schemas.json") as f:
        schemas = json.load(f)

    for schema in schemas:
        requests.post("http://localhost:8081/schema", json=schema)

    with open(args.input) as f:
        qpls = json.load(f)

    result = []
    for ex in qpls:
        ex["valid"] = requests.post(
            "http://localhost:8081/validate", json={"qpl": ex["qpl"]}
        ).json()
        result.append(ex)

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)


if __name__ == "__main__":
    main()
