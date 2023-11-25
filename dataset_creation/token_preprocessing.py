import argparse
import json
from pathlib import Path

import regex as re


def normalize(qpl: str) -> str:
    def white_space_fix(s):
        # Remove double and triple spaces
        return " ".join(s.split())

    def lower(s):
        # Convert everything except text between (single or double) quotation marks to lower case
        return re.sub(
            r"\b(?<!['\"])(\w+)(?!['\"])\b", lambda match: match.group(1).lower(), s
        )

    return white_space_fix(lower(qpl))


def token_preprocess(qpl: str) -> str:
    # Insert spaces between line number and column name
    qpl = re.sub(r"(#\d+)\.(\w+)", r"\1 . \2", qpl)
    # Insert spaces between underscores
    qpl = re.sub(r"(?<=\w)_(?=\w)", " _ ", qpl)
    # Insert spaces between parens
    qpl = re.sub(r"(\()", " ( ", qpl)
    qpl = re.sub(r"(\))", " )", qpl)
    # Replace special tokens
    qpl = (
        qpl.replace(" AVG (", " average (")
        .replace(" DESC ", " descending ")
        .replace(" ASC ", " ascending ")
    )
    return normalize(qpl)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    with open(args.input) as f:
        qpls = json.load(f)

    result = []
    for ex in qpls:
        qpl = ex["qpl"].split(" | ")[1]
        ex["token_preprocessed"] = token_preprocess(qpl)
        result.append(ex)

    with open(args.output, "w") as f:
        json.dump(result, f, indent=2)


if __name__ == "__main__":
    main()
