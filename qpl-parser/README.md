# QPL Parser

This module contains Haskell code for an incremental parser in the spirit of [PICARD](https://github.com/ServiceNow/picard),
only instead of parsing raw SQL, it parses QPL.

The parser exposes the following REST endpoints:

- `/tokenizer` for registering a tokenizer with the parser. The parser will use the registered tokenizer to convert from token IDs to strings.
- `/schema` for registering a schema with the parser.
- `/parse` for incrementally parsing either a partial or full QPL string.
- `/validate` for validating whether a QPL string is valid.

## How to Use

TODO
