# Fine-tuning

The scripts in this module are for fine-tuning a HuggingFace Seq2Seq model on the question-to-QPL task.

## Main Scripts

1. `finetune.py` - contains prompt creation and fine-tuning code of FlanT5-XL using HuggingFace Transformers' `Trainer` class.
2. `picard.py` - contains code to generate QPL predictions on the development set of Spider-QPL using the PICARD method (needs the server from [here](https://github.com/bgunlp/qpl/tree/main/qpl-parser) to run in the background).

## Fine-tuning Details

The model has been fine-tuned on a single NVIDIA A100 80GB GPU for 15 epochs and early stopping with a patience of 5.
