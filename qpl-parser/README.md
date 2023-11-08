# QPL Parser

This module contains Scala code for an incremental parser in the spirit of [PICARD](https://github.com/ServiceNow/picard),
only instead of parsing raw SQL, it parses QPL.

The parser exposes the following REST endpoints:

- `/tokenizer` for registering a tokenizer with the parser. The parser will use the registered tokenizer to convert from token IDs to strings.
- `/schema` for registering a schema with the parser.
- `/parse` for incrementally parsing either a partial or full QPL string.
- `/validate` for validating whether a QPL string is valid.
- `/docs` for a Swagger documentation page where you can try out requests.

## Prerequisites

If not using the Docker image, all you need is Scala-CLI which can be downloaded from [here](https://scala-cli.virtuslab.org/).
It will take care of downloading suitable Java Development Kit and Scala versions.

## Libraries in Use

- [atto](https://tpolecat.github.io/atto/) - An incremental parser based on Haskell's [attoparsec](https://hackage.haskell.org/package/attoparsec)
- [tapir](https://github.com/softwaremill/tapir) - For creating a typed API easily
- [ZIO](https://zio.dev/) - For handling concurrency in the API

## How to Use

### The Easiest Option

Use the pre-packaged Docker image by running: `docker run -p 8081:8081 beneyal/qpl-parser-scala:latest`

### The Easy Option

Open a terminal in the directory where this `README.md` is placed, and run `scala-cli run .`

## Interesting Files

The file `parse.scala` contains all the code for parsing QPL, along with the semantic checks performed during parsing
such as type-checking, key relationships, etc.

The file `Endpoints.scala` is where the server logic lies, which knows how to take a request
that consists of input IDs (that came from a HuggingFace tokenizer), parse it, and return the partial parse
back to the client.
