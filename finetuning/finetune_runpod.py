import os

os.environ["TOKENIZERS_PARALLELISM"] = "false"

import json

import numpy as np
import pandas as pd
import pydash
from datasets import Dataset, concatenate_datasets, load_dataset
from peft import LoraConfig, TaskType, get_peft_model
from sqlalchemy import create_engine
from transformers import (
    AutoModelForSeq2SeqLM,
    AutoTokenizer,
    DataCollatorForSeq2Seq,
    EarlyStoppingCallback,
    Seq2SeqTrainer,
    Seq2SeqTrainingArguments,
)

from qpl_to_cte import flat_qpl_to_cte
from validate_qpl import same_rs

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


def preprocess_function(sample, padding="max_length"):
    inputs = sample["prompt"]

    # tokenize inputs
    model_inputs = tokenizer(inputs, max_length=2048, truncation=True)

    # Tokenize targets with the `text_target` keyword argument
    labels = tokenizer(text_target=sample["target"], max_length=512, truncation=True)

    # If we are padding here, replace all tokenizer.pad_token_id in the labels by -100 when we want to ignore
    # padding in the loss.
    if padding == "max_length":
        labels["input_ids"] = [
            [(l if l != tokenizer.pad_token_id else -100) for l in label]
            for label in labels["input_ids"]
        ]

    model_inputs["labels"] = labels["input_ids"]
    return model_inputs


cache = {}


def check_predictions_on_dev(preds):
    engine = create_engine(
        "mssql+pyodbc://bene:Passw0rd!@spider-qpl.database.windows.net/spider_full?driver=ODBC+Driver+18+for+SQL+Server",
    )

    correct = 0
    total = 0
    for gold, pred in zip(validation, preds):
        total += 1
        tmp = pred.split(" | ")
        if len(tmp) != 2:
            continue
        pred_db_id, pred_qpl = tmp
        if pred_db_id != gold["db_id"]:
            continue
        if gold["cte"] in cache:
            grs = cache[gold["cte"]]
        else:
            grs = pd.read_sql(gold["cte"], engine).to_dict(orient="records")
            cache[gold["cte"]] = grs
        try:
            pred_cte = flat_qpl_to_cte(pred_qpl.split(" ; "), pred_db_id)
            if pred_cte in cache:
                prs = cache[pred_cte]
            else:
                prs = pd.read_sql(pred_cte, engine).to_dict(orient="records")
                cache[pred_cte] = prs
        except:
            pass
        else:
            if same_rs(grs, prs, gold["qpl"].split(" ; ")):
                correct += 1

    engine.dispose()
    return correct / total


def compute_metrics(eval_preds):
    preds, _ = eval_preds
    if isinstance(preds, tuple):
        preds = preds[0]
    preds = np.where(preds != -100, preds, tokenizer.pad_token_id)
    decoded_preds = tokenizer.batch_decode(preds, skip_special_tokens=True)

    acc = check_predictions_on_dev(decoded_preds)

    return {"execution_accuracy": round(100 * acc, 4)}


if __name__ == "__main__":
    dataset_id = "bgunlp/spider-qpl"
    model_id = "google/flan-t5-xl"

    dataset = load_dataset(dataset_id, token=True).map(create_prompt)
    train = dataset["train"]
    validation = dataset["validation"]

    print(f"Train dataset size: {len(train)}")
    print(f"Test dataset size: {len(validation)}")

    tokenizer = AutoTokenizer.from_pretrained(model_id, model_max_length=2048)
    tokenizer.add_tokens([" <=", " <>", " <"])

    # The maximum total input sequence length after tokenization.
    # Sequences longer than this will be truncated, sequences shorter will be padded.
    tokenized_inputs = concatenate_datasets([train, validation]).map(
        lambda x: tokenizer(x["prompt"], truncation=True),
        batched=True,
        remove_columns=train.column_names,
    )
    max_source_length = max([len(x) for x in tokenized_inputs["input_ids"]])
    print(f"Max source length: {max_source_length}")

    # The maximum total sequence length for target text after tokenization.
    # Sequences longer than this will be truncated, sequences shorter will be padded."
    tokenized_targets = concatenate_datasets([train, validation]).map(
        lambda x: tokenizer(x["target"], truncation=True, max_length=512),
        batched=True,
        remove_columns=train.column_names,
    )
    max_target_length = max([len(x) for x in tokenized_targets["input_ids"]])
    print(f"Max target length: {max_target_length}")

    tokenized_dataset = dataset.map(
        preprocess_function, batched=True, remove_columns=train.column_names
    )
    tokenized_train = tokenized_dataset["train"]
    tokenized_validation = tokenized_dataset["validation"]
    print(f"Keys of tokenized dataset: {list(tokenized_train.features)}")

    peft_config = LoraConfig(
        task_type=TaskType.SEQ_2_SEQ_LM,
        inference_mode=False,
        r=16,
        target_modules=["q", "v"],
        lora_alpha=32,
        lora_dropout=0.05,
        bias="none",
    )
    model = AutoModelForSeq2SeqLM.from_pretrained(model_id, device_map="auto")
    model.resize_token_embeddings(len(tokenizer))
    model = get_peft_model(model, peft_config)
    model.print_trainable_parameters()

    # we want to ignore tokenizer pad token in the loss
    label_pad_token_id = -100

    # Data collator
    data_collator = DataCollatorForSeq2Seq(
        tokenizer,
        model=model,
        label_pad_token_id=label_pad_token_id,
        pad_to_multiple_of=8,
    )

    # Hugging Face repository id
    repository_id = (
        f"{model_id.split('/')[1]}-spider-qpl-token-preprocessing-lora-20231217"
    )

    # Define training args
    training_args = Seq2SeqTrainingArguments(
        output_dir=repository_id,
        evaluation_strategy="epoch",
        per_device_train_batch_size=1,
        learning_rate=2e-4,
        num_train_epochs=15,
        logging_strategy="steps",
        logging_steps=500,
        save_strategy="epoch",
        seed=1,
        load_best_model_at_end=True,
        metric_for_best_model="execution_accuracy",
        greater_is_better=True,
        report_to=["wandb"],
        hub_private_repo=True,
        predict_with_generate=True,
        generation_max_length=max_target_length,
    )

    # Create Trainer instance
    trainer = Seq2SeqTrainer(
        model=model,
        args=training_args,
        data_collator=data_collator,
        train_dataset=tokenized_train,
        eval_dataset=tokenized_validation,
        tokenizer=tokenizer,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=5)],
    )

    trainer.train()

    trainer.push_to_hub()
