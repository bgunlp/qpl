# Fine-tuning

The scripts in this module are for fine-tuning a HuggingFace Seq2Seq model on the question-to-QPL task.

## Main Script

- `finetune.py` - contains prompt creation and fine-tuning code of [Flan-T5-XL](https://huggingface.co/google/flan-t5-xl) (3B parameters) using HuggingFace Transformers' `Trainer` class.

## Fine-tuning Details

The model has been fine-tuned on a single NVIDIA A100 80GB GPU for 15 epochs and early stopping with a patience of 5.

| Hyperparameter     | Value |
| ------------------ | ----- |
| # Epoch            | 15    |
| Dropout Prob.      | 0.05  |
| Batch Size         | 1     |
| Learning Rate      | 0.0002|
| Adaptation (r)     | 16    |
| LoRA α             | 32    |
