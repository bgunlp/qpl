# Query Plan Language (QPL)

This repository contains all relevant code and data for our Query Plan Language (QPL). It is the official implementation of the paper "Semantic Decomposition of Question and SQL for Text-to-SQL Parsing" (EMNLP Findings 2023).
Every sub-directory has its own `README.md` file explaining how to use the module.

If you use this repository, please cite the following paper:

```
@inproceedings{eyal-etal-2023-semantic,
    title = "Semantic Decomposition of Question and {SQL} for Text-to-{SQL} Parsing",
    author = "Eyal, Ben  and
      Mahabi, Moran  and
      Haroche, Ophir  and
      Bachar, Amir  and
      Elhadad, Michael",
    editor = "Bouamor, Houda  and
      Pino, Juan  and
      Bali, Kalika",
    booktitle = "Findings of the Association for Computational Linguistics: EMNLP 2023",
    month = dec,
    year = "2023",
    address = "Singapore",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2023.findings-emnlp.910",
    doi = "10.18653/v1/2023.findings-emnlp.910",
    pages = "13629--13645",
    abstract = "Text-to-SQL semantic parsing faces challenges in generalizing to cross-domain and complex queries. Recent research has employed a question decomposition strategy to enhance the parsing of complex SQL queries.However, this strategy encounters two major obstacles: (1) existing datasets lack question decomposition; (2) due to the syntactic complexity of SQL, most complex queries cannot be disentangled into sub-queries that can be readily recomposed. To address these challenges, we propose a new modular Query Plan Language (QPL) that systematically decomposes SQL queries into simple and regular sub-queries. We develop a translator from SQL to QPL by leveraging analysis of SQL server query optimization plans, and we augment the Spider dataset with QPL programs. Experimental results demonstrate that the modular nature of QPL benefits existing semantic-parsing architectures, and training text-to-QPL parsers is more effective than text-to-SQL parsing for semantically equivalent queries. The QPL approach offers two additional advantages: (1) QPL programs can be paraphrased as simple questions, which allows us to create a dataset of (complex question, decomposed questions). Training on this dataset, we obtain a Question Decomposer for data retrieval that is sensitive to database schemas. (2) QPL is more accessible to non-experts for complex queries, leading to more interpretable output from the semantic parser.",
}
```

The repository contains all needed components to run the following stages, using Docker containers:
- Run all the databases in an MSSQL server Docker with content available and access the content using MSSQL query tools (`/database_creation`)
- Run the translation from the original Spider SQL to QPL (`/dataset_creation`)
- Execute QPL queries on the MSSQL database using a Web UI (`/run_qpl`)
- Code to compare the resultset execution of a QPL query with the expected resultset (Execution Match) (`same_rs` function in `/dataset_creation/validate_qpl.py`)
- Code to fine-tune a Flan-T5 base model into a Text-to-QPL semantic parser (`/finetune`)
- Run the fine-tuned Spider-QPL Text-to-QPL model on new queries and schemas (`/inference`)

Links to the fine-tuned Flan-T5-XL model on HuggingFace will be provided shortly (Jan 2024).

The Spider-QPL dataset is available in [JSON format](https://github.com/bgunlp/qpl/tree/main/dataset_creation/output).

The HuggingFace dataset version will be available shortly (Jan 2024).
