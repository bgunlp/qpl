import time
import json
from typing import Any

from dataset_creation.ehrsql2024.dataset_translation import (
    dataset_translate_to_tsql,
    dataset_add_tsql_answers,
    dataset_validate_translated_tsql_answers,
)
from dataset_creation.ehrsql2024.qpl_creation import (
    dataset_add_eps, dataset_add_qpls_raw, dataset_add_qpls_pp,
)
from dataset_creation.ehrsql2024.cte_creation import (
    dataset_add_ctes,
    dataset_add_cte_answers,
    fix_qpls_with_redundant_cols_in_cte_ans,
    dataset_validate_cte_answers,
)
from dataset_creation.ehrsql2024.util import (
    json_load, json_list_write, get_progress_bar, dictify, file_write
)
from dataset_creation.ehrsql2024.constants import (
    tsql_qpl_cte_ans_eq_filepath, ehrsql2024_paths_tuples, tsql_qpl_cte_basename
)

def main():
    dataset_translate_to_tsql()
    dataset_add_tsql_answers()
    dataset_validate_translated_tsql_answers()

    dataset_add_eps()
    dataset_add_qpls_raw()
    dataset_add_qpls_pp()

    dataset_add_ctes()
    dataset_add_cte_answers()
    fix_qpls_with_redundant_cols_in_cte_ans()
    dataset_add_ctes(is_re_run=True)
    dataset_add_cte_answers(is_re_run=True)
    dataset_validate_cte_answers()

    final_dataset_split()


# =========================================================
#   Finalizing dataset:
# =========================================================
def final_dataset_split(dataset_name='EHRSQL-2024-QPL'):
    print()
    tsql_qpl_cte_ans_eq_data = json_load(tsql_qpl_cte_ans_eq_filepath)
    tsql_qpl_cte_data_dct = dictify(tsql_qpl_cte_ans_eq_data)

    total = 0
    total_orig = 0

    missing_ids = {}

    for data_path, label_path, _, data_name in ehrsql2024_paths_tuples:
        print()
        data = json_load(data_path)
        label = json_load(label_path)

        queries_null = 0
        ehrsql2024_qpl_part = []
        ehrsql2024_qpl_part_filepath = f"out/{tsql_qpl_cte_basename}_{data_name}.json"

        missing_ids_part = []

        first_iteration = True
        for query_data in get_progress_bar(data['data'], f'Creating final {dataset_name} dataset for [{data_name}]'):
            if first_iteration:  # Just to make it appear nice on screen
                time.sleep(0.1)
                first_iteration = False

            sqlite = label[query_data['id']]
            if sqlite == 'null':
                queries_null += 1
                ehrsql2024_qpl_part.append(_create_final_dataset_null_query_element(query_data))
            else:
                if query_data['id'] in tsql_qpl_cte_data_dct:
                    tsql_qpl_cte_data = tsql_qpl_cte_data_dct[query_data['id']]
                    ehrsql2024_qpl_part.append(_create_final_dataset_non_null_query_element(tsql_qpl_cte_data))
                else:
                    missing_ids_part.append(query_data['id'])

        missing_ids[data_name] = missing_ids_part

        total += len(ehrsql2024_qpl_part)
        total_orig += len(data['data'])

        print(f"{len(ehrsql2024_qpl_part)} entries in '{data_name}' "
              f"(original amount: {len(data['data'])}, "
              f"missing: {len(data['data']) - len(ehrsql2024_qpl_part)})\n"
              f"\tnon-null queries: {len(ehrsql2024_qpl_part) - queries_null}\n"
              f"\tnull queries: {queries_null}")
        json_list_write(ehrsql2024_qpl_part, ehrsql2024_qpl_part_filepath)

    print(f"\nFinal {dataset_name} contains {total} entries in total "
          f"(original amount: {total_orig}, "
          f"missing: {total_orig - total})\n\n")

    missing_ids_filepath = "out/ehrsql2024_final_dataset_missing_ids.json"
    print(f'Writing missing IDs data to [{missing_ids_filepath}]')
    file_write(json.dumps(missing_ids, indent=4), missing_ids_filepath)

def _create_final_dataset_non_null_query_element(query_data: dict[str, Any]) -> dict[str, Any]:
    return _create_final_dataset_element(
        _id=query_data['id'],
        question=query_data['question'],

        sqlite=query_data['sqlite'],
        sqlite_ans=query_data['sqlite_ans'],

        tsql=query_data['tsql'],
        tsql_ans=query_data['tsql_final_ans'],

        qpl=query_data['qpl'],
        cte=query_data['cte'],
        cte_ans=query_data['cte_final_ans'],
    )

def _create_final_dataset_null_query_element(query_data: dict[str, Any]) -> dict[str, Any]:
    return _create_final_dataset_element(query_data['id'], query_data['question'])

def _create_final_dataset_element(_id, question,
                                  sqlite='null', sqlite_ans=None,
                                  tsql='null', tsql_ans=None,
                                  qpl='null', cte='null', cte_ans=None) -> dict[str, Any]:
    return {
        'id': _id,
        'question': question,

        'sqlite': sqlite,
        'sqlite_ans': [] if sqlite_ans is None else sqlite_ans,

        'tsql': tsql,
        'tsql_ans': [] if tsql_ans is None else tsql_ans,

        'qpl': qpl,
        'cte': cte,
        'cte_ans': [] if cte_ans is None else cte_ans
    }


if __name__ == "__main__":
    main()
