# QPL Dataset Creation

## Prerequisities

In order to create the QPL dataset, you need:

- Python 3 (we tested it on Python 3.10, but it should work for other versions)
- Scala-CLI (can be found [here](https://scala-cli.virtuslab.org/))
- A copy of the Spider dataset (can be found [here](https://yale-lily.github.io/spider))
- A running instance of the Spider database on port 1433 (use the docker container in `./database_creation`).
- A running instance of PICARD running on port 8081 (use the docker container in `./qpl-parser`).

## Pipeline

Assuming you have extracted the Spider dataset to `~/spider`, perform the following steps:

1. Generate execution plans: `python spider_to_tsql_execution_plans.py -s ~/spider -o output`
2. Generate QPL: `for SPLIT in {train,dev}; do scala-cli run mssql-execution-plans-to-qpl -- -s ~/spider -i output/${SPLIT}_spider_with_ep.json -o output/${SPLIT}_qpl.json; done`
3. Post-process QPL: `for SPLIT in {train,dev}; do python post_process_qpl.py -i output/${SPLIT}_qpl.json -o output/${SPLIT}_pp_qpl.json; done`
4. Create CTEs: `for SPLIT in {train,dev}; do python qpl_to_cte.py -i output/${SPLIT}_pp_qpl.json -o output/${SPLIT}_with_cte.json; done`
5. Run queries for syntax and result validation: `for SPLIT in {train,dev}; do python run_queries.py -i output/${SPLIT}_with_cte.json -o output/${SPLIT}_with_rs.pkl; done`
6. Validate QPLs: `for SPLIT in {train,dev}; do python validate_qpl.py -i output/${SPLIT}_with_rs.pkl -o output/${SPLIT}.json; done`
7. Finalize dataset: `for SPLIT in {train,dev}; do python normalize_queries.py -i output/${SPLIT}.json -o output/${SPLIT}.json; done`

