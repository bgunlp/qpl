import re

import sqlglot

from dataset_creation.ehrsql2024.dataset_translation import (
    dataset_add_sqlite_answers, is_equal_ans_cells, dataset_add_tsql_answers
)
from dataset_creation.ehrsql2024.util import (
    file_remove, json_load, get_progress_bar, json_list_write, match_and_replace, dictify, file_write
)


def main():
    validation_predicted_sqlite_notemp_filenames = [                                          # 1 (validation)
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_notemp_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_sqlite_qwen_notemp_unified.json',
    ]
    validation_predicted_sqlite_filenames = [                                                 # 2 (validation)
        # 'ehrsql2024_valid_predicted_sqlite_qwen.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_sqlite_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_sqlite_qwen_unified.json',
    ]
    validation_predicted_tsql_no_user_func_filenames = [                                      # 3 (validation)
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen.json',
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_tsql_no_user_func_qwen_unified.json',
    ]
    validation_predicted_tsql_with_user_func_filenames = [                                     # 4 (validation)
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen.json',
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_valid_predicted_tsql_with_user_func_qwen_unified.json',
    ]

    test_predicted_sqlite_notemp_filenames = [                                                 # 1 (test)
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_notemp_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_sqlite_qwen_notemp_unified.json',
    ]
    test_predicted_sqlite_filenames = [                                                        # 2 (test)
        # 'ehrsql2024_test_predicted_sqlite_qwen.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_sqlite_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_sqlite_qwen_unified.json',
    ]
    test_predicted_tsql_no_user_func_filenames = [                                             # 3 (test)
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen.json',
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_tsql_no_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_tsql_no_user_func_qwen_unified.json',
    ]
    test_predicted_tsql_with_user_func_filenames = [                                           # 4 (test)
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen.json',
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen_ans_err_fixed.json',
        # 'ehrsql2024_test_predicted_tsql_with_user_func_qwen_ans_empty_fixed.json',
        'ehrsql2024_test_predicted_tsql_with_user_func_qwen_unified.json',
    ]

    predicted_sql_triplets_filenames = [
        validation_predicted_sqlite_notemp_filenames, validation_predicted_sqlite_filenames,
        validation_predicted_tsql_no_user_func_filenames,
        validation_predicted_tsql_with_user_func_filenames,
        test_predicted_sqlite_notemp_filenames, test_predicted_sqlite_filenames,
        test_predicted_tsql_no_user_func_filenames,
        test_predicted_tsql_with_user_func_filenames
    ]
    predicted_sql_filenames = [f for triplet in predicted_sql_triplets_filenames for f in triplet]

    validate_predicted_sql_answers(predicted_sql_filenames)
    # validate_predicted_sql_answers(predicted_sql_filenames, '11_validated_sql_answers_summary.txt', filter_leave_temporal_gold_tsql)
    # validate_predicted_sql_answers(predicted_sql_filenames, '12_validated_sql_answers_summary.txt', filter_leave_non_temporal_gold_tsql)

    # unify_all_predicted_sqls_with_fixed_sqls(predicted_sql_triplets_filenames)

    # validated_dataset_calculate_sql_features_distribution(predicted_sql_filenames)


# =====================================================================================================================


def validated_dataset_calculate_sql_features_distribution(predicted_sql_filenames, out_filepath='validated_sql_answers_features_split.json'):
    dict_to_print = {}

    for pred_filename in predicted_sql_filenames:
        dict_per_filename = {}

        if pred_filename.endswith('_ans_err_fixed.json'):
            subfolder_name = 'ans_err_fixed'
        elif pred_filename.endswith('_ans_empty_fixed.json'):
            subfolder_name = 'ans_empty_fixed'
        elif pred_filename.endswith('_unified.json'):
            subfolder_name = 'preds_fixed_unified'
        else:
            subfolder_name = 'preds'

        validated_preds_folder = f'validation_out/{subfolder_name}'
        pred_basename = pred_filename.replace('.json', '')

        total_dict = {
            "has_join": 0.0,
            "has_group_by": 0.0,
            "has_order_by": 0.0,
            "has_aggregation": 0.0,
            "has_nested": 0.0,
            "has_temporal": 0.0,
            "has_code_filtering": 0.0,
        }
        total_length = 0
        for suffix in ['_ans_ok_eq.json', '_ans_ok_uneq.json', '_ans_err.json', '_ans_empty.json']:
            subset_dict = {
                "has_join": 0.0,
                "has_group_by": 0.0,
                "has_order_by": 0.0,
                "has_aggregation": 0.0,
                "has_nested": 0.0,
                "has_temporal": 0.0,
                "has_code_filtering": 0.0,
            }
            valid_pred_filepath = f'{validated_preds_folder}/{pred_basename}{suffix}'
            valid_pred_data = json_load(valid_pred_filepath)
            total_length += len(valid_pred_data)

            for sql_data in get_progress_bar(valid_pred_data, f"Extracting SQL features from [{valid_pred_filepath}]"):
                features = extract_sql_features_tsql(sql_data['tsql'])
                for k in features:
                    subset_dict[k] += features[k]
                    total_dict[k] += features[k]

            for _k in subset_dict:
                subset_dict[_k] = round(subset_dict[_k] / len(valid_pred_data) * 100, 2)
            dict_per_filename[suffix] = subset_dict

        for _k in total_dict:
            total_dict[_k] = round(total_dict[_k] / total_length * 100, 2)
        dict_per_filename['total'] = total_dict
        dict_to_print[pred_basename] = dict_per_filename
        print('\n')

    json_list_write(dict_to_print, out_filepath)


# ---- SQL feature extraction and filtering : ----

def filter_leave_temporal_gold_tsql(sql_data):
    features = extract_sql_features_tsql(sql_data['tsql'])
    return features['has_temporal']

def filter_leave_non_temporal_gold_tsql(sql_data):
    features = extract_sql_features_tsql(sql_data['tsql'])
    return not features['has_temporal']

def extract_sql_features_tsql(sql_string: str,) -> dict[str, bool]:
    """
    Extract boolean features from a SQL query string to analyze its complexity.
    This function analyzes a SQL query string and identifies the presence of various
    SQL features that indicate query complexity, adapted for T-SQL (MS SQL Server) syntax.

    Args:
        sql_string (str): The SQL query string to analyze.

    Returns:
        dict[str, bool]: A dictionary containing boolean flags for detected SQL features:
            - has_join: True if the query contains any JOIN operation
            - has_group_by: True if the query contains GROUP BY clause
            - has_order_by: True if the query contains ORDER BY clause
            - has_aggregation: True if the query contains aggregation functions
              (COUNT, SUM, AVG, MAX, MIN)
            - has_nested: True if the query contains nested SELECT statements
            - has_temporal: True if the query contains T-SQL temporal functions
              (GETDATE, DATEADD, DATEDIFF, DATEPART, etc.)
            - has_code_filtering: True if the query contains a column compared to a string literal

    Note:
        If the input is not a string, all features will be marked as False.
        The function performs case-insensitive matching by converting the SQL
        string to uppercase before analysis.

    Example:
        >> extract_sql_features_sqlite("SELECT COUNT(*) FROM Users u JOIN Orders o ON u.id = o.UserId WHERE o.OrderDate > DATEADD(day, -1, GETDATE())")
        {'has_join': True, 'has_group_by': False, 'has_order_by': False,
         'has_aggregation': True, 'has_nested': False, 'has_temporal': True, 'has_code_filtering': False}
    """

    if not isinstance(sql_string, str):
        print("not a string:", sql_string)
        return {
            "has_join": False,
            "has_group_by": False,
            "has_order_by": False,
            "has_aggregation": False,
            "has_nested": False,
            "has_temporal": False,
            "has_code_filtering": False,
        }

    sql = sql_string.upper()

    # Detects SQL conditions where a column is compared to a string literal.
    # Regex Breakdown:
    # \b(?:\w+\.)?     : Matches an optional table/alias prefix and a dot (e.g., "users.")
    # \w+\b            : Matches the column name (e.g., "status")
    # \s* : Matches optional whitespace
    # (?:=|!=|<>|LIKE) : Matches the comparison operator
    # \s* : Matches optional whitespace
    # (['\"])          : Group 1 - Matches the opening quote (single or double)
    # (.*?)            : Group 2 - Matches the string content inside the quotes
    # \1               : Backreference to Group 1 (ensures the closing quote matches the opening quote)
    # Examples caught: status = 'active', users.role != "admin", t1.email LIKE '%@gmail.com'
    has_code_filtering_pattern = r"\b(?:\w+\.)?\w+\b\s*(?:=|!=|<>|LIKE)\s*(['\"])(.*?)\1"

    # List of common T-SQL temporal functions
    tsql_temporal_funcs = [
        "GETDATE",  # Current timestamp
        "SYSDATETIME",  # High precision current timestamp
        "DATEADD",  # Add interval to date
        "DATEDIFF",  # Difference between dates
        "DATEPART",  # Extract part of date
        "DATENAME",  # Extract name of date part
        "YEAR(",  # Standard extraction (with parenthesis to avoid matching column names like 'YEARLY')
        "MONTH(",
        "DAY(",
        "ISDATE",  # Check if valid date
        "EOMONTH",  # End of month
    ]
    temporal_abstract_funcs = [
        "dbo.DURING",
        "dbo.MET_BY",
        "dbo.TIME_INTERVAL_YMD",
        "dbo.TIME_POINT_START_OF_YMD",
        "dbo.TIME_POINT_YMDHMS",
        "dbo.TIME_INTERVAL_REL",
        "dbo.TIME_POINT",
    ]
    temporal_funcs = tsql_temporal_funcs  + temporal_abstract_funcs

    features = {
        "has_join": "JOIN" in sql,
        "has_group_by": "GROUP BY" in sql,
        "has_order_by": "ORDER BY" in sql,
        "has_aggregation": any(agg in sql for agg in ["COUNT(", "SUM(", "AVG(", "MAX(", "MIN("]),
        # The \s* ensures we catch "(SELECT", "( SELECT", and "(  SELECT"
        "has_nested": bool(re.search(r"\(\s*SELECT", sql)),
        "has_temporal": any(term.upper() in sql for term in temporal_funcs),
        "has_code_filtering": bool(re.search(has_code_filtering_pattern, sql)),
    }

    return features


# ---- Validating answers: ----

def validate_predicted_sql_answers(predicted_sql_filenames, out_filename='validated_sql_answers_summary.txt', filter_method=None):
    """
    Prints the cleaned stdout of `_validate_predicted_sql_answers` into a file
    """
    import io
    from contextlib import redirect_stdout

    def _clean_stdout(text):
        text = match_and_replace(text, [
            # (r'Post-processing predicted [\w-]+ \[\w+/\w+/', '# '),

            # (r'\]:\s*\d+%.*',         ''),
            # (r'Writing to.*',         ''),

            (r'Writing to .*_ans_.', ''),
            (r'Writing to \[\w+\/\w+\/', '# '),

            (r'_unified_pp.json\]', ''),
            (r'Adding.*', ''),
            (r'Deleting.*', ''),
            (r'Validating.*', ''),

            (r'empty [\w-]+ answers', 'empty answers'),
            (r'successfully added non-empty answers', 'OK answers'),
            (r'failed attempts to add [\w-]+ answer', 'errors'),
            (r'predicted queries with answer', 'answers'),
            (r'Final accuracy score', 'Accuracy'),

            (r'^(?!\s*$)(?!(?:\d+|#|Accuracy:)).*', ''),

            (r'\n+', r'\n'),
            (r'#', r'\n#'),

            # (r'# [\w\.]+\n\n',           ''),

        ], flags=[re.RegexFlag.IGNORECASE, re.RegexFlag.MULTILINE])
        return text

    # Create a file-like object in memory to write to:
    f = io.StringIO()

    # The code block whose output we want to capture:
    with redirect_stdout(f):
        _validate_predicted_sql_answers(predicted_sql_filenames, filter_method)

    # After the 'with' block, standard output is restored to normal
    s = f.getvalue()
    file_write(_clean_stdout(s), out_filename)

def _validate_predicted_sql_answers(predicted_sql_filenames, filter_method=None):
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

        pp_method(pred_filepath, pred_pp_filepath, pred_attr_name, filter_method)
        add_ans_method(pred_pp_filepath, pred_ans_ok_filepath, pred_attr_name)
        dataset_validate_predicted_sql_answers(pred_ans_ok_filepath, pred_ans_attr_name, ex_ans_attr_name, pred_pp_filepath, ex_ans_attr_name_alt)  # ! pred_filepath -> pred_pp_filepath
        file_remove(pred_pp_filepath)  # ~
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

def dataset_validate_predicted_sql_answers(in_pred_ans_filepath, pred_ans_attr_name, ex_ans_attr_name, pred_pp_filepath, ex_ans_attr_name_alt=None):
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
    preds_non_null_exist_in_dataset = list(filter(lambda x: x['sqlite'] != 'null' and pred_attr_name in x, json_load(pred_pp_filepath)))
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
    # file_remove(in_pred_filepath)

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
    # file_remove(in_pred_filepath)


# ---- Initial post-processing of predicted SQL: ----

def post_process_predicted_sqlite(in_filepath, out_filepath, sqlite_attr_name, filter_method=None):
    sql_pred_data = json_load(in_filepath)
    sql_pred_data_pp = []
    for e in get_progress_bar(sql_pred_data, f"Post-processing predicted SQLites [{in_filepath}]"):
        if sqlite_attr_name in e:
            if filter_method is None or filter_method(e):
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

                sql_pred_data_pp.append(e)

    json_list_write(sql_pred_data_pp, out_filepath)

def post_process_predicted_tsql(in_filepath, out_filepath, tsql_attr_name, filter_method=None):
    sql_pred_data = json_load(in_filepath)
    sql_pred_data_pp = []
    for e in get_progress_bar(sql_pred_data, f"Post-processing predicted T-SQLs [{in_filepath}]"):
        if tsql_attr_name in e:
            if filter_method is None or filter_method(e):
                tsql = e[tsql_attr_name]

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

                sql_pred_data_pp.append(e)

    json_list_write(sql_pred_data_pp, out_filepath)


if __name__ == "__main__":
    main()
