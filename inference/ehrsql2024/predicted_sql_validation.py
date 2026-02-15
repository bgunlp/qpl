import re

import sqlglot

from dataset_creation.ehrsql2024.dataset_translation import (
    dataset_add_sqlite_answers, is_equal_ans_cells, dataset_add_tsql_answers
)
from dataset_creation.ehrsql2024.util import (
    file_remove, json_load, get_progress_bar, json_list_write, match_and_replace, dictify
)


def main():
    validation_predicted_sqlite_notemp_filenames = [                                          # 3 (validation)
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_sqlite_qwen_notemp_unified.json',
    ]
    validation_predicted_sqlite_filenames = [                                                 # 4 (validation)
        # 'ehrsql2024_valid_predicted_sqlite_qwen.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_sqlite_qwen_unified.json',
    ]
    validation_predicted_tsql_no_user_func_filenames = [                                      # 5 (validation)
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen.json',
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_unified.json',
    ]
    validation_predicted_tsql_with_user_func_filenames = [                                     # 6 (validation)
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen.json',
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_unified.json',
    ]

    test_predicted_sqlite_notemp_filenames = [                                                 # 3 (test)
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_sqlite_qwen_notemp_unified.json',
    ]
    test_predicted_sqlite_filenames = [                                                        # 4 (test)
        # 'ehrsql2024_test_predicted_sqlite_qwen.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_sqlite_qwen_unified.json',
    ]
    test_predicted_tsql_no_user_func_filenames = [                                             # 5 (test)
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen.json',
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_tsql_no_user_func_qwen_unified.json',
    ]
    test_predicted_tsql_with_user_func_filenames = [                                           # 6 (test)
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen.json',
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_tsql_with_user_func_qwen_unified.json',
    ]

    predicted_sql_triplets_filenames = [
        validation_predicted_sqlite_notemp_filenames, validation_predicted_sqlite_filenames,
        validation_predicted_tsql_no_user_func_filenames, validation_predicted_tsql_with_user_func_filenames,
        test_predicted_sqlite_notemp_filenames, test_predicted_sqlite_filenames,
        test_predicted_tsql_no_user_func_filenames, test_predicted_tsql_with_user_func_filenames
    ]
    predicted_sql_filenames = [f for triplet in predicted_sql_triplets_filenames for f in triplet]

    validate_predicted_sql_answers(predicted_sql_filenames)
    # unify_all_predicted_sqls_with_fixed_sqls(predicted_sql_triplets_filenames)


# =====================================================================================================================


def validate_predicted_sql_answers(predicted_sql_filenames):
    for pred_filename in predicted_sql_filenames:
        if '_sqlite_' in pred_filename:
            datatype = 'sqlite'
            pp_method = post_process_predicted_sqlite
            add_ans_method = dataset_add_predicted_sqlite_answers
        elif '_tsql_' in pred_filename:
            datatype = 'tsql'
            pp_method = post_process_predicted_tsql
            add_ans_method = dataset_add_predicted_tsql_answers
        else:
            raise ValueError(f'Unknown filename: {pred_filename}')

        pred_attr_name = f'{datatype}_predicted'
        pred_ans_attr_name = f'{pred_attr_name}_ans'
        ex_ans_attr_name = f'{datatype}_ans'
        ex_ans_attr_name_alt = 'sqlite_ans' if datatype == 'tsql' else None

        if pred_filename.endswith('_ans_err_fixed.json'):
            subfolder_name = 'ans_err_fixed'
        elif pred_filename.endswith('_ans_empty_fixed.json'):
            subfolder_name = 'ans_empty_fixed'
        elif pred_filename.endswith('_unified.json'):
            subfolder_name = 'preds_fixed_unified'
        else:
            subfolder_name = 'preds'

        pred_filepath = f'validation_in/{subfolder_name}/{pred_filename}'
        pred_pp_filepath = f'validation_out/{subfolder_name}/' + pred_filename.replace('.json', '_pp.json')
        pred_ans_ok_filepath = f'validation_out/{subfolder_name}/' + pred_filename.replace('.json', '_ans_ok.json')

        pp_method(pred_filepath, pred_pp_filepath, pred_attr_name)
        add_ans_method(pred_pp_filepath, pred_ans_ok_filepath, pred_attr_name)
        dataset_validate_predicted_sql_answers(pred_ans_ok_filepath, pred_ans_attr_name, ex_ans_attr_name, pred_filepath, ex_ans_attr_name_alt)
        print('\n\n')


# ---- Unifying predicted SQL with fixed SQL: ----

def unify_all_predicted_sqls_with_fixed_sqls(predicted_sql_triplets_filenames: list[list[str]]):
    for pred_triplet_filenames in predicted_sql_triplets_filenames:
        pred_filename = pred_triplet_filenames[0]
        err_fixed_filename = pred_triplet_filenames[1]
        empty_fixed_filename = pred_triplet_filenames[2]
        unify_predicted_sqls_with_fixed_sqls(pred_filename, err_fixed_filename, empty_fixed_filename)
        print('\n')

def unify_predicted_sqls_with_fixed_sqls(pred_filename, err_fixed_filename, empty_fixed_filename):
    _unify_predicted_sqls_with_fixed_sqls(
        preds_filepath=f'validation_in/preds/{pred_filename}',
        err_fixes_filepath=f'validation_in/ans_err_fixed/{err_fixed_filename}',
        empty_fixes_filepath=f'validation_in/ans_empty_fixed/{empty_fixed_filename}',
        pred_sql_attr_name='sqlite_predicted' if '_sqlite_' in pred_filename else 'tsql_predicted',
        unified_preds_filepath=f"validation_in/preds_fixed_unified/{pred_filename.replace('.json', '_unified.json')}"
    )

def _unify_predicted_sqls_with_fixed_sqls(preds_filepath, err_fixes_filepath, empty_fixes_filepath, pred_sql_attr_name, unified_preds_filepath):
    err_fixes_dict = dictify(json_load(err_fixes_filepath))
    empty_fixes_dict = dictify(json_load(empty_fixes_filepath))
    preds_data = json_load(preds_filepath)

    for pred_data in get_progress_bar(preds_data, f"Unifying predicted SQLs [{preds_filepath}] "
                                                  f"with fixed SQLs [{err_fixes_filepath}] "
                                                  f"and [{empty_fixes_filepath}]"):
        if pred_sql_attr_name in pred_data:
            if pred_data['id'] in err_fixes_dict:
                pred_data[pred_sql_attr_name] = err_fixes_dict[pred_data['id']][pred_sql_attr_name]
                pred_data['prediction_full_ans'] = err_fixes_dict[pred_data['id']]['prediction_full_ans']
            elif pred_data['id'] in empty_fixes_dict:
                pred_data[pred_sql_attr_name] = empty_fixes_dict[pred_data['id']][pred_sql_attr_name]
                pred_data['prediction_full_ans'] = empty_fixes_dict[pred_data['id']]['prediction_full_ans']

    json_list_write(preds_data, unified_preds_filepath)


# ---- Comparing answers: ----

def dataset_validate_predicted_sql_answers(in_pred_ans_filepath, pred_ans_attr_name, ex_ans_attr_name, pred_filepath, ex_ans_attr_name_alt=None):
    print('\n')
    eq_filepath = in_pred_ans_filepath.replace('.json', '_eq.json')
    uneq_filepath = in_pred_ans_filepath.replace('.json', '_uneq.json')

    eq = []
    uneq = []

    sql_pred_data = json_load(in_pred_ans_filepath)
    for e in get_progress_bar(sql_pred_data, f"Validating predicted SQL answers [{in_pred_ans_filepath}]"):
        gold_query = e['sqlite']
        pred_cell = e[pred_ans_attr_name]
        ex_cell = e[ex_ans_attr_name]
        ex_cell_alt = e[ex_ans_attr_name_alt] if ex_ans_attr_name_alt else None

        # if e['id'] == '6df8c8add4bde78a73d76071':
        #     ...

        if is_predicted_ans_equal_to_expected(pred_cell, ex_cell, gold_query):
            eq.append(e)
        else:
            # Alternative checks:
            if (
                    ex_cell_alt and
                    gold_query.startswith("SELECT 24 * ( strftime(") and
                    is_predicted_ans_equal_to_expected(pred_cell, ex_cell_alt, gold_query, True)
            ):
                eq.append(e)
            # elif (
            #         ex_cell_alt and
            #         is_predicted_ans_equal_to_expected(pred_cell, ex_cell_alt, gold_query)
            # ):
            #     eq.append(e)
            else:
                uneq.append(e)

    print(f'\n{len(eq)} predicted queries with answer equal to expected')
    json_list_write(eq, eq_filepath)

    print(f'\n{len(uneq)} predicted queries with answer different than expected')
    json_list_write(uneq, uneq_filepath)

    pred_attr_name = pred_ans_attr_name.replace('_ans', '')
    preds_non_null_exist_in_dataset = list(filter(lambda x: x['sqlite'] != 'null' and pred_attr_name in x, json_load(pred_filepath)))
    print(f'\nFinal accuracy score: {(len(eq) / len(preds_non_null_exist_in_dataset) * 100):.2f}')

    file_remove(in_pred_ans_filepath)

def is_predicted_ans_equal_to_expected(pred_rows: list[list[str]], exp_rows: list[list[str]], query_gold: str, alt_check=False):
    """
    Assumptions:
        1.  Each element of @pred_rows represent PREDICTED SQL result row
            1.1.    Each PREDICTED row MAY contain multiple cells
            1.2.    A PREDICTED cell MAY be equal to the expected answer: the "RELEVANT cell"

        2.  Each element of @expected_rows represent EXPECTED SQL result row
            2.1.    Contains only SINGLE cell: the expected answer

        3.  @pred_rows and @expected_rows are EQUAL if:
            [3.1.   Same LENGTH if gold query start with SELECT DISTINCT]
            3.2.    Each predicted row contains at least ONE RELEVANT cell
            3.3.    Same LENGTH of UNIQUE RELEVANT PREDICTED cells and UNIQUE EXPECTED cells
            3.4.    Same VALUE of UNIQUE RELEVANT PREDICTED cells and UNIQUE EXPECTED cells
            [[3.5.  Same ORDER of UNIQUE RELEVANT PREDICTED cells and UNIQUE EXPECTED cells, if ORDER BY validation_in gold query]]
    """

    # if query_gold.lower().startswith("select distinct"):
    #     if not len(pred_rows) == len(exp_rows):
    #         return False  # 3.1

    exp_cells_unique = list(set([r[0] for r in exp_rows]))  # 2.1

    pred_cells_relevant = []
    for pred_row in pred_rows:
        pred_cell_relevant = None
        for exp_cell in exp_cells_unique:
            if pred_cell_relevant := is_cell_contained_in_row(exp_cell, pred_row, alt_check):  # 1.1 + 1.2
                pred_cells_relevant.append(pred_cell_relevant)
                break  # only one relevant cell per predicted row
        if pred_cell_relevant is None:
            return False  # 3.2

    pred_cells_relevant_unique = list(set(pred_cells_relevant))
    if not len(pred_cells_relevant_unique) == len(exp_cells_unique):
        return False  # 3.3 + 3.4 holds

    # if "order by" validation_in query_gold.lower():  # 3.5
    #     #     # TODO: maybe omit check?
    #     #     for i validation_in range(len(exp_cells_unique)):
    #         if not is_equal_ans_cells(pred_cells_relevant_unique[i], exp_cells_unique[i]):
    #             return False

    return True

def is_cell_contained_in_row(cell_ex, row_pred, alt_check=False):
    for row_cell in row_pred:

        # In case result is time-interval JSON, take value of date_start (better than nothing):  [?]
        if m := re.match(r'{"date_start":"(\d+-\d+-\d+T\d+:\d+:\d+)","date_end"', row_cell):
            row_cell = m.group(1)

        if is_equal_ans_cells(row_cell, cell_ex, alt_check):
            return row_cell
    return None


# ---- Adding answers: ----

def dataset_add_predicted_tsql_answers(in_pred_filepath, out_pred_ans_ok_filepath, tsql_attr_name):
    dataset_add_tsql_answers(in_pred_filepath, out_pred_ans_ok_filepath, tsql_attr_name, False)
    file_remove(in_pred_filepath)

    ok = []
    empty = []
    ans_attr_name = f'{tsql_attr_name}_ans'
    ans_empty_filepath = out_pred_ans_ok_filepath.replace('_ok.json', '_empty.json')

    for tsql_data in json_load(out_pred_ans_ok_filepath):
        if ans_attr_name in tsql_data:
            ans = tsql_data[ans_attr_name]
            if len(ans) == 0 or ans[0][0] == 'null':
                empty.append(tsql_data)
            else:
                ok.append(tsql_data)

    print(f"\n{len(ok)} successfully added non-empty T-SQL answers")
    json_list_write(ok, out_pred_ans_ok_filepath)

    print(f"\n{len(empty)} empty T-SQL answers")
    json_list_write(empty, ans_empty_filepath)

def dataset_add_predicted_sqlite_answers(in_pred_filepath, out_pred_ans_ok_filepath, sqlite_attr_name):
    dataset_add_sqlite_answers(in_pred_filepath, out_pred_ans_ok_filepath, sqlite_attr_name)
    file_remove(in_pred_filepath)


# ---- Initial post-processing of predicted SQL: ----

def post_process_predicted_sqlite(in_filepath, out_filepath, sqlite_attr_name):
    sql_pred_data = json_load(in_filepath)
    for e in get_progress_bar(sql_pred_data, f"Post-processing predicted SQLites [{in_filepath}]"):
        if sqlite_attr_name in e:
            e[sqlite_attr_name] = match_and_replace(e[sqlite_attr_name], [
                # Lowercase all comparable string literals:
                (r" = ('[^']+')", lambda m: f' = {m.group(1).lower()}'),

                # Lowercase all string literals (without wildcards):
                # (r"('[^']+')", lambda m: f'{m.group(1).lower()}'),  # if '%' not validation_in m.group(1) else m.group(1)

                # Convert boolean strings to integers:
                (r"THEN 'yes'", "THEN 1"),
                (r"THEN 'no'", "THEN 0"),
                (r"ELSE 'yes'", "ELSE 1"),
                (r"ELSE 'no'", "ELSE 0"),
                (r"THEN 'greater'", "THEN 1"),
                (r"THEN 'not greater'", "THEN 0"),
                (r"ELSE 'greater'", "ELSE 1"),
                (r"ELSE 'not greater'", "ELSE 0"),
            ], flags=[re.RegexFlag.IGNORECASE])

    json_list_write(sql_pred_data, out_filepath)

def post_process_predicted_tsql(in_filepath, out_filepath, tsql_attr_name):
    sql_pred_data = json_load(in_filepath)
    for e in get_progress_bar(sql_pred_data, f"Post-processing predicted T-SQLs [{in_filepath}]"):
        if tsql_attr_name in e:
            tsql = e[tsql_attr_name]

            # if e['id'] == '6df8c8add4bde78a73d76071':
            #     ...

            # Try fix non-TSQL code:
            try:
                tsql = match_and_replace(tsql, [("DATEDIFF", "DATEDIFFF")])  # weird fix for weird sqlglot behavior [1]
                tsql_fixed = sqlglot.transpile(tsql, read="sqlite", write="tsql")[0]
                e[tsql_attr_name] = match_and_replace(tsql_fixed, [("DATEDIFFF", "DATEDIFF")])  # weird fix for weird sqlglot behavior [2]
            except Exception as ex:
                ...

            e[tsql_attr_name] = match_and_replace(e[tsql_attr_name], [

                # Add missing 'dbo.' prefixes:
                (r"([\s,]+)(DURING|MET_BY|TIME_POINT|TIME_INTERVAL_YMD|TIME_POINT_YMDHMS|TIME_POINT_START_OF_YMD|TIME_INTERVAL_REL)(\s*\()",
                 lambda m: f'{m.group(1)}dbo.{m.group(2)}{m.group(3)}'
                           if m.group(2)
                           else m.group(0)
                 ),

                # Remove wrong 'dbo.' prefixes:
                (r"dbo.DATEADD", "DATEADD"),
                (r"dbo.DATEDIFF", "DATEDIFF"),
                (r"dbo.GETDATE", "GETDATE"),

                # Lowercase all comparable string literals:
                (r" = ('[^']+')", lambda m: f' = {m.group(1).lower()}'),

                # Convert boolean strings to integers:
                (r"THEN 'yes'", "THEN 1"),
                (r"THEN 'no'", "THEN 0"),
                (r"ELSE 'yes'", "ELSE 1"),
                (r"ELSE 'no'", "ELSE 0"),
                (r"THEN 'greater'", "THEN 1"),
                (r"THEN 'not greater'", "THEN 0"),
                (r"ELSE 'greater'", "ELSE 1"),
                (r"ELSE 'not greater'", "ELSE 0"),

                # T-SQL syntax fix:  [?]
                (r"(?<!OFFSET \d ROWS )FETCH FIRST \d+ ROWS ONLY", lambda m: f'OFFSET 0 ROWS {m.group(0)}'),

            ], flags=[re.RegexFlag.IGNORECASE])

    json_list_write(sql_pred_data, out_filepath)


if __name__ == "__main__":
    main()
