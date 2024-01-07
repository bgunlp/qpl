import argparse
import json
import logging
import pathlib

import datasets
import pydash
import requests
import torch
from peft import AutoPeftModelForSeq2SeqLM
from tqdm.auto import tqdm
from transformers import (
    AutoTokenizer,
    GenerationConfig,
    LogitsProcessor,
    LogitsProcessorList,
)

logging.basicConfig(filename="picard.log", level=logging.INFO)

parser = argparse.ArgumentParser()
parser.add_argument("model_id")
parser.add_argument("output", type=pathlib.Path)
args = parser.parse_args()
outfile = args.output

with open("./db_schemas.json") as f:
    db_schemas = json.load(f)

with open("./db_content.json") as f:
    db_content = json.load(f)


def update_type(col_type):
    if "char" in col_type or col_type == "" or "text" in col_type or "var" in col_type:
        return "text"
    elif (
        "int" in col_type
        or "numeric" in col_type
        or "decimal" in col_type
        or "number" in col_type
        or "id" in col_type
        or "real" in col_type
        or "double" in col_type
        or "float" in col_type
    ):
        return "number"
    elif "date" in col_type or "time" in col_type:
        return "date"
    elif "boolean" in col_type or col_type == "bit":
        return "boolean"
    else:
        return "others"


def create_table_prompt(
    sample, add_db_content=True, add_column_types=True, add_pk=True, add_fk=True
):
    db_id = sample["db_id"]
    tables = db_schemas[db_id]["tables"]
    pk = db_schemas[db_id].get("pk", None)
    fk = db_schemas[db_id].get("fk", None)

    content = db_content[sample["id"]]["db_content"]

    formatted_columns = lambda table_name, columns: ",\n".join(
        [
            "\t{column_name}{column_type}{content}".format(
                column_name=column[0],
                column_type=f" {update_type(column[1])}" if add_column_types else "",
                content=f" ( {' , '.join(content[table_name][column[0]])} )"
                if add_db_content and pydash.has(content, f"{table_name}.{column[0]}")
                else "",
            )
            for column in columns
        ]
    )

    formatted_table_pk = lambda table_pk: ",\n\tprimary key ( {table_pk} )".format(
        table_pk=" , ".join(table_pk)
    )

    formatted_table_fk = lambda table_fk: ",\n{table_fk}".format(
        table_fk=",\n".join(
            [
                "\tforeign key ( {fk_columns_name} ) references {referenced_table_name} ( {referenced_columns_name} )".format(
                    fk_columns_name=" , ".join(
                        [fk_column[0] for fk_column in fk_columns]
                    ),
                    referenced_table_name=referenced_table_name,
                    referenced_columns_name=" , ".join(
                        [fk_column[1] for fk_column in fk_columns]
                    ),
                )
                for referenced_table_name, fk_columns in table_fk.items()
            ]
        )
    )

    prompt = "\n\n".join(
        [
            "CREATE TABLE {table_name} (\n{formatted_columns}{formatted_table_pk}{formatted_table_fk}\n)".format(
                table_name=table_name,
                formatted_columns=formatted_columns(table_name, columns),
                formatted_table_pk=formatted_table_pk(pk[table_name])
                if add_pk and pk and pydash.has(pk, table_name)
                else "",
                formatted_table_fk=formatted_table_fk(fk[table_name])
                if add_fk and fk and pydash.has(fk, table_name)
                else "",
            )
            for table_name, columns in tables.items()
        ]
    )

    return prompt


def create_prompt(sample):
    db_id = sample["db_id"]

    prompt = (
        f"{db_id}\n\n"
        + create_table_prompt(sample)
        + "\n\n"
        + "-- Using valid QPL, answer the following questions for the tables provided above."
        + f"""\n\n-- {sample["question"].strip()}\n\n[QPL]: """
    )

    return {"prompt": prompt, "target": f"{db_id} | {sample['qpl']}"}


def preprocess_function(sample):
    return tokenizer(
        sample["prompt"], max_length=2048, truncation=True, padding="max_length"
    )


dataset = datasets.load_dataset("bgunlp/spider-qpl", split="validation").map(
    create_prompt
)


model = AutoPeftModelForSeq2SeqLM.from_pretrained(args.model_id, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(
    args.model_id,
    model_max_length=2048,
)

requests.post(
    "http://localhost:8081/tokenizer",
    data=tokenizer.backend_tokenizer.to_str(pretty=False).encode("utf-8"),
    headers={"Content-Type": "application/json"},
)

tokenized_inputs = dataset.map(
    lambda x: tokenizer(x["prompt"], truncation=True),
    batched=True,
    remove_columns=dataset.column_names,
)
max_source_length = max([len(x) for x in tokenized_inputs["input_ids"]])
print(f"Max source length: {max_source_length}")


tokenized_dataset = dataset.map(
    preprocess_function,
    batched=True,
    remove_columns=dataset.column_names,
)
print(f"Keys of tokenized dataset: {list(tokenized_dataset.features)}")

with open("./schemas.json") as f:
    db_id_to_schema = {s["db_id"]: s for s in json.load(f)}

schemas = set()
for sample in dataset:
    db_id = sample["db_id"]
    if db_id not in schemas:
        schemas.add(db_id)
        schema = db_id_to_schema[db_id]
        res = requests.post("http://localhost:8081/schema", json=schema)
        if res.status_code != 200:
            raise ValueError(f"Oops, couldn't register schema: {schema}")


class PicardQplLogitsProcessor(LogitsProcessor):
    def _batch_mask_top_k(self, indices_to_remove, input_ids, top_tokens):
        req = {"input_ids": input_ids.tolist(), "top_tokens": top_tokens.tolist()}
        res = requests.post("http://localhost:8081/parse", json=req).json()
        for r in res:
            batch_id = r["batch_id"]
            feed_result = r["feed_result"]
            feed_result_tag = feed_result["tag"]
            top_token = r["top_token"]

            if feed_result_tag == "failure":
                indices_to_remove[batch_id, top_token] = True
            elif feed_result_tag == "partial":
                pass
            elif feed_result_tag == "complete":
                pass
            else:
                raise ValueError("Unexpected FeedResult")

    @torch.inference_mode()
    def __call__(self, input_ids, scores):
        top_k = min(8, scores.size(-1))  # Safety check
        top_scores, top_tokens = torch.topk(scores, top_k)
        # Remove all tokens with a probability less than the last token of the top-k
        lowest_top_k_scores = top_scores[..., -1, None]
        del top_scores
        indices_to_remove = scores < lowest_top_k_scores
        del lowest_top_k_scores
        # Do not mask the EOS token because otherwise production can continue indefinitely if all other tokens are masked
        indices_to_remove[:, tokenizer.eos_token_id] = False
        # Mask top-k tokens rejected by picard
        self._batch_mask_top_k(
            indices_to_remove=indices_to_remove,
            input_ids=input_ids,
            top_tokens=top_tokens,
        )
        del top_tokens
        scores = scores.masked_fill(indices_to_remove, torch.finfo(scores.dtype).min)
        del indices_to_remove
        return scores


ds = tokenized_dataset.with_format("torch", device="cuda")
dataloader = torch.utils.data.DataLoader(ds, batch_size=2)
logits_processor = LogitsProcessorList([PicardQplLogitsProcessor()])
generation_config = GenerationConfig(max_new_tokens=512, num_beams=8)

generated_plans = []
for batch in tqdm(dataloader):
    plans = tokenizer.batch_decode(
        model.generate(
            **batch,
            generation_config=generation_config,
            logits_processor=logits_processor,
        ),
        skip_special_tokens=True,
    )
    for p in plans:
        logging.info(p)
    generated_plans.extend(plans)

with open(outfile, "w", encoding="utf-8") as f:
    json.dump(generated_plans, f, indent=2)
