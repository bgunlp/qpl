# Text-to-QPL Inference

The file in this module allows running inference using the PICARD QPL parser module on unseen data, given as a HuggingFace dataset.

## How to Run

1. Make sure the PICARD server is running (instructions on how to do so are [here](https://github.com/bgunlp/qpl/tree/main/qpl-parser))
2. Run `picard.py <path-to-model> <output-path>` (on Spider-QPL's validation set with ~1K samples this takes roughly 4 hours)
