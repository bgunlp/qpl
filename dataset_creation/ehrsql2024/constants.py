ehrsql2024_path = r"C:\Users\Stas\PycharmProjects\EHRSQL\mimic_iv"  # TODO: get from user args
ehrsql2024_valid_path = fr"{ehrsql2024_path}\valid"
ehrsql2024_test_path = fr"{ehrsql2024_path}\test"
ehrsql2024_train_path = fr"{ehrsql2024_path}\train"
ehrsql2024_paths_tuples = [
    (
        fr"{ehrsql2024_valid_path}\data.json",
        fr"{ehrsql2024_valid_path}\label.json",
        fr"{ehrsql2024_valid_path}\answer.json",
        'valid'
    ),
    (
        fr"{ehrsql2024_test_path}\data.json",
        fr"{ehrsql2024_test_path}\label.json",
        fr"{ehrsql2024_test_path}\answer.json",
        'test'
    ),
    (
        fr"{ehrsql2024_train_path}\data.json",
        fr"{ehrsql2024_train_path}\label.json",
        fr"{ehrsql2024_train_path}\answer.json",
        'train'
    )
]


dataset_basename = 'ehrsql2024'

tsql_basename = f"{dataset_basename}_tsql"
tsql_filepath = f"out/{tsql_basename}.json"

tsql_ans_basename = f"{tsql_basename}_ans"
tsql_ans_ok_filepath = f"out/{tsql_ans_basename}_ok.json"
tsql_ans_err_filepath = f"out/{tsql_ans_basename}_err.json"

tsql_ans_eq_filepath = f"out/{tsql_ans_basename}_eq.json"
tsql_ans_uneq_filepath = f"out/{tsql_ans_basename}_uneq.json"

tsql_ep_basename = f"{tsql_basename}_ep"
tsql_ep_ok_filepath = f"out/{tsql_ep_basename}_ok.json"
tsql_ep_err_filepath = f"out/{tsql_ep_basename}_err.json"

tsql_qpl_basename = f"{tsql_basename}_qpl"

tsql_qpl_raw_basename = f"{tsql_qpl_basename}_raw"
tsql_qpl_raw_ok_filepath = f"out/{tsql_qpl_raw_basename}_ok.json"
tsql_qpl_raw_err_filepath = f"out/{tsql_qpl_raw_basename}_err.json"

tsql_qpl_pp_basename = f"{tsql_qpl_basename}_pp"
tsql_qpl_pp_ok_filepath = f"out/{tsql_qpl_pp_basename}_ok.json"
tsql_qpl_pp_err_filepath = f"out/{tsql_qpl_pp_basename}_err.json"

tsql_qpl_cte_basename = f"{tsql_qpl_basename}_cte"
tsql_qpl_cte_ok_filepath = f"out/{tsql_qpl_cte_basename}_ok.json"
tsql_qpl_cte_err_filepath = f"out/{tsql_qpl_cte_basename}_err.json"

tsql_qpl_cte_ans_basename = f"{tsql_qpl_cte_basename}_ans"
tsql_qpl_cte_ans_ok_filepath = f"out/{tsql_qpl_cte_ans_basename}_ok.json"
tsql_qpl_cte_ans_err_filepath = f"out/{tsql_qpl_cte_ans_basename}_err.json"
cte_ans_redundant_columns_filepath = f"out/{dataset_basename}_cte_ans_redundant_columns.json"

tsql_qpl_cte_ans_eq_filepath = f"out/{tsql_qpl_cte_ans_basename}_eq.json"
tsql_qpl_cte_ans_uneq_filepath = f"out/{tsql_qpl_cte_ans_basename}_uneq.json"
cte_ans_missing_distinct_filepath = f"out/{dataset_basename}_cte_missing_distinct.json"