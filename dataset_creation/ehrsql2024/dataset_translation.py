import numpy as np
import json
import sqlglot
import re

from datetime import datetime as dt

from sqlglot.optimizer.simplify import catch

from dataset_creation.ehrsql2024.util import (
    json_load, json_list_write, get_progress_bar, file_remove,
    match_and_replace, MimicIvConnectionManager, get_capture_groups_matches
)
from dataset_creation.ehrsql2024.constants import (
    ehrsql2024_paths_tuples, tsql_filepath, tsql_ans_eq_filepath,
    tsql_ans_uneq_filepath, tsql_ans_ok_filepath, tsql_ans_err_filepath,
)

# =========================================================
#               Adding SQLite answers:
# =========================================================
def dataset_add_sqlite_answers(in_filepath, out_filepath=None, sqlite_attr_name='sqlite'):
    import sqlite3
    ehrsql2024_sqlite_db_path = r"C:\Users\Stas\Downloads\mimic_iv.sqlite"  # TODO: get from user args
    print('\n')

    out_filepath = in_filepath if out_filepath is None else out_filepath
    sqlite_ans_attribute_name = f'{sqlite_attr_name}_ans'

    if '_ok.json' in out_filepath:
        ans_err_filepath = out_filepath.replace('_ok.json', '_err.json')
        ans_empty_filepath = out_filepath.replace('_ok.json', '_empty.json')
    else:
        ans_err_filepath = out_filepath.replace('.json', '_err.json')
        ans_empty_filepath = out_filepath.replace('.json', '_empty.json')

    ok = []
    err = []
    empty = []
    with sqlite3.connect(ehrsql2024_sqlite_db_path) as conn:
        for tsql_data in get_progress_bar(json_load(in_filepath), f"Adding SQLite answers [dataset='{in_filepath}']"):
            if sqlite_attr_name in tsql_data:
                sqlite_post_processed = sqlite_post_process(tsql_data[sqlite_attr_name])
                conn.row_factory = sqlite3.Row
                cur = conn.cursor()
                try:
                    cur.execute(sqlite_post_processed)
                    sqlite_ans = [[str(c) if c is not None else 'null' for c in list(row)]
                                  for row in cur.fetchall()]
                    tsql_data[sqlite_ans_attribute_name] = sqlite_ans
                    if len(sqlite_ans) == 0 or sqlite_ans[0][0] == 'null':
                        empty.append(tsql_data)
                    else:
                        ok.append(tsql_data)
                except Exception as e:
                    tsql_data[sqlite_ans_attribute_name] = str(e)
                    err.append(tsql_data)

    print(f"\n{len(ok)} successfully added non-empty SQLite answers")
    json_list_write(ok, out_filepath)

    print(f"\n{len(err)} failed attempts to add SQLite answer")
    json_list_write(err, ans_err_filepath)

    print(f"\n{len(empty)} empty SQLite answers")
    json_list_write(empty, ans_empty_filepath)

def sqlite_post_process(query):
    """
    According to https://github.com/glee4810/ehrsql-2024/blob/master/scoring_program/postprocessing.py
    """

    CURRENT_DATE = "2100-12-31"
    CURRENT_TIME = "23:59:00"
    NOW = f"{CURRENT_DATE} {CURRENT_TIME}"
    PRECOMPUTED_DICT = {
        'temperature': (35.5, 38.1),
        'sao2': (95.0, 100.0),
        'heart rate': (60.0, 100.0),
        'respiration': (12.0, 18.0),
        'systolic bp': (90.0, 120.0),
        'diastolic bp': (60.0, 90.0),
        'mean bp': (60.0, 110.0)
    }
    TIME_PATTERN = r"(DATE_SUB|DATE_ADD)\((\w+\(\)|'[^']+')[, ]+ INTERVAL (\d+) (MONTH|YEAR|DAY)\)"

    def __convert_date_function(match):
        function = match.group(1)
        date = match.group(2)
        number = match.group(3)
        unit = match.group(4).lower()

        # Use singular form when number is 1
        if number == '1':
            unit = unit.rstrip('s')
        else:
            unit += 's' if not unit.endswith('s') else ''

        # Determine the sign based on the function (DATE_SUB or DATE_ADD)
        sign = '-' if function == 'DATE_SUB' else '+'

        return f"datetime({date}, '{sign}{number} {unit}')"

    query = re.sub('[ ]+', ' ', query.replace('\n', ' ')).strip()
    query = query.replace('> =', '>=').replace('< =', '<=').replace('! =', '!=')

    query = query.replace(  # due to inconsistency between versions of MIMIC-IV:
        'totalamount',  # inputevents.
        "amount")      # inputevents.

    # Convert MySQL to SQLite functions
    query = re.sub(TIME_PATTERN, __convert_date_function, query)

    if "current_time" in query:  # strftime('%J',current_time) => strftime('%J','2100-12-31 23:59:00')
        query = query.replace("current_time", f"'{NOW}'")
    if "current_date" in query:  # strftime('%J',current_date) => strftime('%J','2100-12-31')
        query = query.replace("current_date", f"'{CURRENT_DATE}'")
    if "'now'" in query:  # 'now' => '2100-12-31 23:59:00'
        query = query.replace("'now'", f"'{NOW}'")
    if "NOW()" in query:  # NOW() => '2100-12-31 23:59:00'
        query = query.replace("NOW()", f"'{NOW}'")
    if "CURDATE()" in query:  # CURDATE() => '2100-12-31'
        query = query.replace("CURDATE()", f"'{CURRENT_DATE}'")
    if "CURTIME()" in query:  # CURTIME() => '23:59:00'
        query = query.replace("CURTIME()", f"'{CURRENT_TIME}'")

    if re.search('[ \n]+([a-zA-Z0-9_]+_lower)', query) and re.search('[ \n]+([a-zA-Z0-9_]+_upper)', query):
        vital_lower_expr = re.findall('[ \n]+([a-zA-Z0-9_]+_lower)', query)[0]
        vital_upper_expr = re.findall('[ \n]+([a-zA-Z0-9_]+_upper)', query)[0]
        vital_name_list = list(
            set(re.findall('([a-zA-Z0-9_]+)_lower', vital_lower_expr) +
                re.findall('([a-zA-Z0-9_]+)_upper', vital_upper_expr)))
        if len(vital_name_list) == 1:
            processed_vital_name = vital_name_list[0].replace('_', ' ')
            if processed_vital_name in PRECOMPUTED_DICT:
                vital_range = PRECOMPUTED_DICT[processed_vital_name]
                query = query.replace(vital_lower_expr, f"{vital_range[0]}").replace(vital_upper_expr, f"{vital_range[1]}")

    query = query.replace("%y", "%Y").replace('%j', '%J')

    return query


# =========================================================
#               Translation validation:
# =========================================================

# ---- Comparing results: ----

def dataset_validate_translated_tsql_answers():
    """
    Validate the answers of the T-SQLs against the answers of the corresponding SQLites they translated from
    """
    # TODO: maybe use pandas
    translated_ok_eq = []
    translated_ok_uneq = []

    for tsql_ans_data in json_load(tsql_ans_ok_filepath):
        if is_equal_answers(tsql_ans_data['tsql_for_translation_validation_ans'], tsql_ans_data['sqlite_ans'], tsql_ans_data['sqlite']):
            translated_ok_eq.append(tsql_ans_data)
        else:
            translated_ok_uneq.append(tsql_ans_data)

    print(f'\n{len(translated_ok_eq)} translated queries with answer equal to expected')
    json_list_write(translated_ok_eq, tsql_ans_eq_filepath)

    print(f'\n{len(translated_ok_uneq)} translated queries with answer different than expected')
    json_list_write(translated_ok_uneq, tsql_ans_uneq_filepath)

    file_remove(tsql_ans_ok_filepath)

def is_equal_answers(new_ans_rows: list[list[str]], expected_ans_rows: list[list[str]], query_gold: str) -> bool:
    """
    Assumptions:
        - Each element of @new_ans_rows and @expected_ans_rows represent SQL result row containing a single cell
    """
    new_ans_cells: list[str] = [row[0] for row in new_ans_rows]  # according to assumption
    expected_ans_cells: list[str] = [row[0] for row in expected_ans_rows]  # according to assumption

    if query_gold.startswith("SELECT DISTINCT"):
        is_equal_len = len(new_ans_cells) == len(expected_ans_cells)
        if not is_equal_len:  # <- optional, more strict  # !!
            return False

    new_ans_cells_unique = list(set(new_ans_cells))
    expected_ans_cells_unique = list(set(expected_ans_cells))
    is_equal_len_unique = len(new_ans_cells_unique) == len(expected_ans_cells_unique)
    if not is_equal_len_unique:  # <- essential  # !!
        return False

    eqs = [False] * len(new_ans_cells_unique)

    alt_check = query_gold.startswith("SELECT 24 * ( strftime(")
    for i, expected_cell in enumerate(expected_ans_cells_unique):
        for new_cell in new_ans_cells_unique:
            if is_equal_ans_cells(new_cell, expected_cell, alt_check):
                eqs[i] = True
                break

    return all(eqs)  # <- essential  # !!

def is_equal_ans_cells(new_cell, expected_cell, alt_check=False):
    # Check if close numbers:
    if is_num(new_cell) and is_num(expected_cell):
        return compare_nums(new_cell, expected_cell, alt_check)

    # Check if same dates, omitting microseconds:
    if is_full_date(new_cell) and is_full_date(expected_cell):
        return compare_full_dates(new_cell, expected_cell)

    # ... else, check if just same strings:
    return new_cell == expected_cell

def compare_full_dates(ans, expected):
    ans = dt.fromisoformat(ans)
    expected = dt.fromisoformat(expected)
    return ans == expected

def compare_nums(ans, expected, alt_check=False):
    ans = float(ans)
    expected = float(expected)

    if alt_check:
        """
        Specific case:
        When validating *T-SQL* answers against gold *SQLite* answer, and there is a date-difference calculation in the 
        query, T-SQL returns *integer* while SQLite returns *float*.
        We want to consider the answers equal if their integer parts are equal:
        """
        if ans.is_integer():
            return int(ans) == int(expected)

    if abs(ans) >= 1 and abs(expected) >= 1:
        return abs(ans - expected) <= 0.1

    return abs(ans - expected) <= 0.001

def is_full_date(string):
    try:
        return bool(dt.strptime(string, '%Y-%m-%d %H:%M:%S'))
    except ValueError:
        try:
            return bool(dt.strptime(string, '%Y-%m-%dT%H:%M:%S'))
        except ValueError:
            try:
                return bool(dt.strptime(string, '%Y-%m-%d %H:%M:%S.%f'))
            except ValueError:
                try:
                    return bool(dt.strptime(string, '%Y-%m-%dT%H:%M:%S.%f'))
                except ValueError:
                    return False

def is_num(string):
    try:
        float(string)
        return True
    except ValueError:
        return False

    def compare_full_dates(ans, expected):
        ans = dt.fromisoformat(ans).strftime('%Y-%m-%d %H:%M:%S')
        expected = dt.fromisoformat(expected).strftime('%Y-%m-%d %H:%M:%S')
        return ans == expected

    # Check if close numbers:
    if is_num(new_cell) and is_num(expected_cell):
        return compare_nums(new_cell, expected_cell)

    # Check if same dates, omitting microseconds:
    # if is_full_date(ans_tsql_row) and is_full_date(ans_expected_row):
    #     if len(ans_tsql_row) != len(ans_expected_row):
    #         return compare_full_dates(ans_tsql_row, ans_expected_row)

    # ... else, check if just same strings:
    return new_cell == expected_cell


# ---- Adding DB answers: ----

def dataset_add_tsql_answers():
    print('\n')
    ok = []
    err = []

    tsqls_data = json_load(tsql_filepath)
    with MimicIvConnectionManager() as conn:
        for tsql_data in get_progress_bar(tsqls_data, f'Adding T-SQL answers'):
            tsql_for_translation_validation = tsql_modify_for_translation_validation(tsql_data['tsql'])
            tsql_data['tsql_for_translation_validation'] = tsql_for_translation_validation
            try:
                tsql_data['tsql_for_translation_validation_ans'] = conn.exec_fetch(tsql_for_translation_validation)
            except Exception as e:
                tsql_data['tsql_for_translation_validation_ans'] = str(e)
                err.append(tsql_data)
                continue

            tsql_final = tsql_modify_for_validation(tsql_data['tsql'])
            tsql_data['tsql_final'] = tsql_final
            try:
                tsql_data['tsql_final_ans'] = conn.exec_fetch(tsql_final)
                ok.append(tsql_data)
            except Exception as e:
                tsql_data['tsql_final_ans'] = str(e)
                err.append(tsql_data)

    print(f"\n{len(ok)} successfully added T-SQL answers")
    json_list_write(ok, tsql_ans_ok_filepath)

    print(f"\n{len(err)} failed attempts to add T-SQL answer")
    json_list_write(err, tsql_ans_err_filepath)

    # file_remove(tsql_filepath)

def tsql_modify_for_translation_validation(tsql: str) -> str:
    """
    Applied on T-SQL (translated from SQLite) to align the results of SQLite and T-SQL to validate the translation.
    """
    tsql_for_validation = tsql_modify_for_validation(tsql)

    return match_and_replace(tsql_for_validation, [
        (r"DATEDIFF\(DAY, ", "dbo.JULIAN_DAY_DIFF("),  # due to numeric differences. see 'v2_temporal_operators_2.sql'
        # (orderby_mod_regex, orderby_mod_replacer)  # modify some 'order-by' clauses that might return duplicate values
    ], [re.IGNORECASE])

def tsql_modify_for_validation(tsql: str) -> str:
    """
    According to https://github.com/glee4810/ehrsql-2024/blob/master/scoring_program/postprocessing.py
    """
    tsql_pp = tsql_post_process(tsql)
    return match_and_replace(tsql_pp, [
        (r"GETDATE\(\)", "CAST('2100-12-31 23:59:00' AS DATETIME)"),
    ], [re.IGNORECASE])

def tsql_post_process(tsql: str) -> str:
    """
    According to https://github.com/glee4810/ehrsql-2024/blob/master/scoring_program/postprocessing.py
    """
    PRECOMPUTED_DICT = {
        'temperature': (35.5, 38.1),
        'sao2': (95.0, 100.0),
        'heart rate': (60.0, 100.0),
        'respiration': (12.0, 18.0),
        'systolic bp': (90.0, 120.0),
        'diastolic bp': (60.0, 90.0),
        'mean bp': (60.0, 110.0)
    }
    if re.search('[ \n]+([a-zA-Z0-9_]+_lower)', tsql) and re.search('[ \n]+([a-zA-Z0-9_]+_upper)', tsql):
        vital_lower_expr = re.findall('[ \n]+([a-zA-Z0-9_]+_lower)', tsql)[0]
        vital_upper_expr = re.findall('[ \n]+([a-zA-Z0-9_]+_upper)', tsql)[0]
        vital_name_list = list(
            set(re.findall('([a-zA-Z0-9_]+)_lower', vital_lower_expr) +
                re.findall('([a-zA-Z0-9_]+)_upper', vital_upper_expr))
        )
        if len(vital_name_list) == 1:
            processed_vital_name = vital_name_list[0].replace('_', ' ')
            if processed_vital_name in PRECOMPUTED_DICT:
                vital_range = PRECOMPUTED_DICT[processed_vital_name]
                tsql = tsql.replace(vital_lower_expr, f"{vital_range[0]}").replace(vital_upper_expr, f"{vital_range[1]}")

    return tsql.replace("totalamount",  # due to inconsistency between versions of MIMIC-IV:
                        "amount")


# =========================================================
#               Dataset translation:
# =========================================================
def dataset_translate_to_tsql():
    import ast
    print()
    queries_null = 0
    translated_non_null = []

    for data_path, label_path, answer_path, data_name in ehrsql2024_paths_tuples:
        data = json_load(data_path)
        label = json_load(label_path)
        answer = json_load(answer_path)

        for query_data in get_progress_bar(data['data'], f'Translating [{data_name}] to T-SQL'):
            sqlite = label[query_data['id']]  # .replace(" )", ")") !!

            if sqlite == 'null':
                queries_null += 1
            else:
                tsql = sqlite_to_tsql(sqlite, translation_tuples)
                sqlite_ans = ast.literal_eval(answer[query_data['id']])
                translated_non_null.append({'id': query_data['id'],
                                            'question': query_data['question'],
                                            'sqlite': sqlite,
                                            'sqlite_ans': sqlite_ans,
                                            'tsql': tsql})

    print(f"\n{len(translated_non_null)} non-null queries translated ({queries_null} null queries found)")
    json_list_write(translated_non_null, tsql_filepath)

def sqlite_to_tsql(sqlite, translation_tuples):
    sqlite_processed = match_and_replace(sqlite, translation_tuples)
    translated_tsql = sqlglot.transpile(sqlite_processed, read="sqlite", write="tsql")[0]
    return finalize_translation(translated_tsql)

def finalize_translation(tsql):
    """
    Post-sqlglot fixes for the T-SQL (translated from SQLite)
    """
    return match_and_replace(tsql, [
        ("DATEDIFFF", "DATEDIFF"),  # weird workaround for sqlglot weird behavior (see date_diff_replacer)
        (subquery_fix_regex, subquery_fix_replacer),  # add alias to sub-queries to make it valid T-SQL
        (r"CAST\((?P<col>[\w\.]+) AS DATETIME2\)", lambda m: m.group('col'))  # remove redundant casting
    ])


# ==================================================================
#        Testing translation regexes (pre and post SQLGlot):
# ==================================================================
def run_translation_tests():
    translation_tuples_all = translation_tuples + post_translation_tuples
    results = [get_translation_test_results(regex, replacer, test_pairs, test_name)
               for (regex, replacer, test_pairs, test_name)
               in translation_tuples_all]

    ans = ''
    test_name_max_len = max([len(name) for (name, mssg) in results])
    for (name, mssg) in results:
        spaces = ' ' * (test_name_max_len - len(name))
        ans += f'\t{name}:  {spaces}{mssg}\n'

    print(f'\nTranslation tests results:\n{ans}')

def get_translation_test_results(regex, replacer, sql_pairs, test_name):
    results = np.array([get_translation_test_result(regex, replacer, sql, sql_expected) for (sql, sql_expected) in sql_pairs])

    failed_idxs = np.where(results == False)[0]
    failed_num = len(failed_idxs)
    passed_num = len(results) - failed_num

    mssg = f'passed: {passed_num}, failed: {failed_num}'
    if failed_num > 0:
        mssg += f', failed indices: {failed_idxs}'

    return test_name, mssg

def get_translation_test_result(regex, replacer, sql, sql_expected):
    sql_new = match_and_replace(sql, [(regex, replacer)])
    return sql_new.lower() == sql_expected.lower()


# =====================================================================================================================
#              Modifications/fixes applied to T-SQL queries AFTER applying SQLGlot translation:
# =====================================================================================================================
# ------------------------------------------------------------------------------
#     Order-by modification (result alignment for translation validation):
# ------------------------------------------------------------------------------
orderby_mod_regex = r"(?<=SELECT TOP 1 )(?:.+)ORDER BY ((?<!T\d\.)[\w\d.\[\]])+( (ASC|DESC))?(?=(\))?$)"
orderby_mod_tests = [
    ("SELECT TOP 1 bla bla ORDER BY admissions.admittime ASC",
     "SELECT TOP 1 bla bla ORDER BY admissions.admittime ASC, row_id"),

    ("(SELECT TOP 1 bla bla ORDER BY admissions.admittime DESC)",
     "(SELECT TOP 1 bla bla ORDER BY admissions.admittime DESC, row_id)"),

    ("(SELECT TOP 1 bla bla ORDER BY admissions.admittime)",
     "(SELECT TOP 1 bla bla ORDER BY admissions.admittime, row_id)"),

    ("SELECT TOP 1 bla bla ORDER BY admissions.admittime",
     "SELECT TOP 1 bla bla ORDER BY admissions.admittime, row_id"),

    ("SELECT TOP 1 bla bla ORDER BY T1.admittime",
     "SELECT TOP 1 bla bla ORDER BY T1.admittime"),

    ("SELECT TOP 1 bla bla ORDER BY admissions.admittime bla bla",
     "SELECT TOP 1 bla bla ORDER BY admissions.admittime bla bla"),

    ("ORDER BY admissions.admittime)",
     "ORDER BY admissions.admittime)"),

    ("DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS C1)",
     "DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS C1)")
]

def orderby_mod_replacer(match):
    """
        To be used with orderby_mod_regex.
        Used for SQLite->T-SQL translation VALIDATION, to make SQLite and T-SQL results align.
        Adds '..., row_id' to some T-SQL 'order-by' clauses that might return duplicate values.
    """
    return f'{match.group(0)}, row_id'


# --------------------------------------------------
#     Sub-queries alias fix (post-translation):
# --------------------------------------------------
subquery_fix_regex = r"^SELECT\s+\S+\s+FROM\s+\(.*\)\s*$"
subquery_fix_tests = [
    ("SELECT AVG(C1) FROM (SELECT bla bla bla)",
     "SELECT AVG(C1) FROM (SELECT bla bla bla) as subqr"),

    ("SELECT AVG(C1) FROM d_icd_diagnoses WHERE d_icd_diagnoses.icd_code IN (SELECT bla bla bla)",
     "SELECT AVG(C1) FROM d_icd_diagnoses WHERE d_icd_diagnoses.icd_code IN (SELECT bla bla bla)")
]

def subquery_fix_replacer(match):
    """
        To be used with subquery_fix_regex.
        Used for FINALIZE SQLite->T-SQL translation.
        Adds alias name to sub-queries to make it valid T-SQL.
    """
    return f'{match.group(0)} as subqr'


# =====================================================================================================================
# Translations and modifications applied to SQLite queries BEFORE applying SQLGlot translation, most refer directly to
# specific Time Templates from EHRSQL paper, and some additional structural translations and fixes:
# =====================================================================================================================
# ----------------------------------------------------------
#        Translation of ABSOLUTE time expressions:
# ----------------------------------------------------------
# strftime(<format>, <datetime>) <op> <datetime_formatted> :
absolute_regex = r"(?P<lhs_abs>strftime\s*\(.+?\))\s*(?P<op_abs>[=<>]+)\s*'(?P<rhs_abs>[^']+)'"  # [-%Ymd]+ --> [-%\w]+;   \s*'[-%\w]+'\s*(,\s*[^,]+)\s*?  --> .+?
absolute_tests = [
    # Q: "... event/s occurred IN 2024"
    ("strftime('%Y', <event_time>) = '2024'",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(2024, NULL, NULL)) = 1"),

    # Q: "... event/s occurred UNTIL 2024"
    ("strftime('%Y', <event_time>) <= '2024'",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT_START_OF_YMD(2024, NULL, NULL)) = 1"),

    # Q: "... event/s occurred SINCE 2024"
    ("strftime('%Y', <event_time>) >= '2024'",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT_START_OF_YMD(2024, NULL, NULL)) = 1"),

    ####################################################################################

    # Q: "... event/s occurred IN 2017-03"
    ("strftime('%Y-%m', schm.table) = '2017-03'",
     "dbo.DURING(schm.table, dbo.TIME_INTERVAL_YMD(2017, 03, NULL)) = 1"),

    # Q: "... event/s occurred UNTIL 2017-03"
    ("strftime('%Y-%m', schm.table) <= '2017-03'",
     "dbo.MEETS(schm.table, dbo.TIME_POINT_START_OF_YMD(2017, 03, NULL)) = 1"),

    # Q: "... event/s occurred SINCE 2017-03"
    ("strftime('%Y-%m', schm.table) >= '2017-03'",
     "dbo.MET_BY(schm.table, dbo.TIME_POINT_START_OF_YMD(2017, 03, NULL)) = 1"),

    ####################################################################################

    # Q: "... event/s occurred ON 2017-03-2"
    ("strftime('%Y-%m-%d', schm.table_2) = '2017-03-2'",
     "dbo.DURING(schm.table_2, dbo.TIME_INTERVAL_YMD(2017, 03, 2)) = 1"),

    # Q: "... event/s occurred UNTIL 2017-03-2"
    ("strftime('%Y-%m-%d', schm.table_2) <= '2017-03-2'",
     "dbo.MEETS(schm.table_2, dbo.TIME_POINT_START_OF_YMD(2017, 03, 2)) = 1"),

    # Q: "... event/s occurred SINCE 2017-03-2"
    ("strftime('%Y-%m-%d', schm.table_2) >= '2017-03-2'",
     "dbo.MET_BY(schm.table_2, dbo.TIME_POINT_START_OF_YMD(2017, 03, 2)) = 1")
]
def absolute_replacer(match):
    """
        To be used with absolute_regex, for:

        'strftime(<format>, <datetime>) <op> <datetime_formatted>'

            <format>:              '%Y-%m-%d' | '%Y-%m' | '%Y'
            <op>:                  '=' | '<=' | '>='
            <datetime_formatted>': '{y}-{m}-{d}' | '{y}-{m}' | '{y}'
    """
    (lhs_format_1st, lhs_format_2nd, lhs_format_3rd, lhs_datetime,
     op,
     rhs_1st, rhs_2nd, rhs_3rd) = absolute_extract_parts(match)
    # strftime('%Y', <event_time>) <op> '{year}'
    if lhs_format_1st == 'Y' and lhs_format_2nd is None and lhs_format_3rd is None and \
            rhs_1st is not None and rhs_2nd is None and rhs_3rd is None:  # TODO: rhs_1st is int
        if op == '=':
            return f"dbo.DURING({lhs_datetime}, dbo.TIME_INTERVAL_YMD({rhs_1st}, NULL, NULL)) = 1"
        if op == '<=':
            return f"dbo.MEETS({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, NULL, NULL)) = 1"
        if op == '>=':
            return f"dbo.MET_BY({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, NULL, NULL)) = 1"

    # strftime('%Y-%m',<event_time>) <op> '{year}-{month}
    if lhs_format_1st == 'Y' and lhs_format_2nd == 'm' and lhs_format_3rd is None and \
            rhs_1st is not None and rhs_2nd is not None and rhs_3rd is None:  # TODO: rhs_1st,rhs_2nd are int
        if op == '=':
            return f"dbo.DURING({lhs_datetime}, dbo.TIME_INTERVAL_YMD({rhs_1st}, {rhs_2nd}, NULL)) = 1"
        if op == '<=':
            return f"dbo.MEETS({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, {rhs_2nd}, NULL)) = 1"
        if op == '>=':
            return f"dbo.MET_BY({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, {rhs_2nd}, NULL)) = 1"

    # strftime('%Y-%m-%d', <event_time>) <op> '{year}-{month}-{day}'
    if lhs_format_1st == 'Y' and lhs_format_2nd == 'm' and lhs_format_3rd == 'd' and \
            rhs_1st is not None and rhs_2nd is not None and rhs_3rd is not None:  # TODO: rhs_1st,rhs_2nd,rhs_3rd are int
        if op == '=':
            return f"dbo.DURING({lhs_datetime}, dbo.TIME_INTERVAL_YMD({rhs_1st}, {rhs_2nd}, {rhs_3rd})) = 1"
        if op == '<=':
            return f"dbo.MEETS({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, {rhs_2nd}, {rhs_3rd})) = 1"
        if op == '>=':
            return f"dbo.MET_BY({lhs_datetime}, dbo.TIME_POINT_START_OF_YMD({rhs_1st}, {rhs_2nd}, {rhs_3rd})) = 1"

    raise ValueError(f"absolute_replace: unknown pattern matched, match = [{match.group(0)}]")


# '2024-03-01', '03-01', '%Y-%m-%d', '%m-%d', etc... :
date_formatted_regex = "(?P<first>[^-]+)(-(?P<second>[^-]+)(-(?P<third>[^-]+))?)?"
def absolute_extract_parts(match):
    lhs = match.group('lhs_abs')  # strftime(<format>, <datetime>)
    op = match.group('op_abs')  # <op>
    rhs = match.group('rhs_abs')  # <datetime_formatted>

    lhs_format_1st, lhs_format_2nd, lhs_format_3rd, lhs_datetime = strftime_clause_extract_parts(lhs)

    rhs_capt_groups = get_capture_groups_matches(date_formatted_regex, rhs)
    rhs_1st = rhs_capt_groups['first']  # rhs [1]
    rhs_2nd = rhs_capt_groups['second']  # rhs [2]
    rhs_3rd = rhs_capt_groups['third']  # rhs [3]

    return (lhs_format_1st, lhs_format_2nd, lhs_format_3rd, lhs_datetime,
            op,
            rhs_1st, rhs_2nd, rhs_3rd)

def strftime_clause_extract_parts(strftime_clause):
    # strftime(<format>, <datetime>)
    strftime_regex = r"strftime\s*\(\s*'(?P<format>[-%\w]+)'\s*(,\s*(?P<datetime>[^,]+)\s*)?\)"  # [-%Ymd]+ --> [-%\w]+
    capt_groups = get_capture_groups_matches(strftime_regex, func_name_translate(strftime_clause))

    datetime = capt_groups['datetime'].strip()

    format_raw = match_and_replace(capt_groups['format'], [('%', '')])  # eliminate '%' chars from captured <format>
    format_capt_groups = get_capture_groups_matches(date_formatted_regex, format_raw)
    format_1st = format_capt_groups['first']
    format_2nd = format_capt_groups['second']
    format_3rd = format_capt_groups['third']

    return format_1st, format_2nd, format_3rd, datetime


# ----------------------------------------------------------------
#        Translation of EXACT-ABSOLUTE time expressions:
# ----------------------------------------------------------------
# datetime(<datetime>) = '{year}-{month}-{day} {hour}:{minute}:{second}'
exact_absolute_regex = r"(?P<lhs>\w+\.\w+)\s*=\s*'(?P<rhs1>\d+)-(?P<rhs2>\d+)-(?P<rhs3>\d+) (?P<rhs4>\d+):(?P<rhs5>\d+):(?P<rhs6>\d+)'"
exact_absolute_tests = [
    ("AND labevents.charttime = '2100-04-02 05:22:00') <",
     "AND dbo.DURING(labevents.charttime, dbo.TIME_POINT_YMDHMS(2100, 04, 02, 05, 22, 00)) = 1) <"),
]
def exact_absolute_replacer(match):
    """
        To be used with exact_abs_regex, for:
        table.col = '{year}-{month}-{day} {hour}:{minute}:{second}'
    """
    datetime = match.group('lhs')
    year = match.group('rhs1')
    month = match.group('rhs2')
    day = match.group('rhs3')
    hour = match.group('rhs4')
    minute = match.group('rhs5')
    sec = match.group('rhs6')

    # <datetime_col> = '{year}-{month}-{day} {hour}:{minute}:{second}'
    return f"dbo.DURING({datetime}, dbo.TIME_POINT_YMDHMS({year}, {month}, {day}, {hour}, {minute}, {sec})) = 1"


# ----------------------------------------------------------
#        Translation of RELATIVE time expressions:
# ----------------------------------------------------------
# datetime(...) <op> datetime(...)
relative_regex = r"(?P<lhs_rel>datetime\(.+?\))\s*(?P<op_rel>[=<>]+)\s*(?P<rhs_rel>datetime\(.+?\))"  # ! .+?
relative_tests = [
    # Q: "... event/s occurred DURING *this* year"
    ("datetime(<event_time>, 'start of year') = datetime(current_time, 'start of year', '-0 year')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(GETDATE(), 'year')) = 1"),

    # Q: "... event/s occurred DURING *this* month"
    ("datetime(<event_time>, 'start of month') = datetime(current_time, 'start of month','-0 month')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(GETDATE(), 'month')) = 1"),

    # Q: "... event/s occurred today (DURING *this* day)"
    ("datetime(<event_time>, 'start of day') = datetime(current_time, 'start of day','-0 day')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(GETDATE(), 'day')) = 1"),

    #############################################################################################################

    # Q: "... event/s occurred DURING *last* year"
    ("datetime(<event_time>, 'start of year') = datetime(current_time, 'start of year', '-1 year')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(DATEADD(YEAR, -1, GETDATE()), 'year')) = 1"),

    # Q: "... event/s occurred UNTIL *last* year"
    ("datetime(<event_time>,'start of year') <= datetime(current_time, 'start of year', '-1 year')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT_REL(DATEADD(YEAR, -1, GETDATE()), 'start-of year')) = 1"),

    # Q: "... event/s occurred SINCE *last* year"
    ("datetime(<event_time>, 'start of year') >= datetime(current_time, 'start of year', '-1 year')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT_REL(DATEADD(YEAR, -1, GETDATE()), 'start-of year')) = 1"),

    #############################################################################################################

    # Q: "... event/s occurred DURING *last* month"
    ("datetime(<event_time>, 'start of month') =datetime(current_time, 'start of month', '-1 month')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(DATEADD(MONTH, -1, GETDATE()), 'month')) = 1"),

    # Q: "... event/s occurred UNTIL *last* month"
    ("datetime(<event_time>, 'start of month')<= datetime(current_time, 'start of month', '-1 month')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT_REL(DATEADD(MONTH, -1, GETDATE()), 'start-of month')) = 1"),

    # Q: "... event/s occurred SINCE *last* month"
    ("datetime(<event_time>, 'start of month')>=datetime(current_time, 'start of month', '-1 month')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT_REL(DATEADD(MONTH, -1, GETDATE()), 'start-of month')) = 1"),

    #############################################################################################################

    # Q: "... event/s occurred yesterday (DURING *last* day")
    ("datetime(<event_time>,'start of day') = datetime(current_time, 'start of day', '-1 day')",
     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_REL(DATEADD(DAY, -1, GETDATE()), 'day')) = 1"),

    # Q: "... event/s occurred UNTIL yesterday (*last* day)"
    ("datetime(<event_time>, 'start of day') <= datetime(current_time,'start of day', '-1 day')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT_REL(DATEADD(DAY, -1, GETDATE()), 'start-of day')) = 1"),

    # Q: "... event/s occurred SINCE yesterday (*last* day)"
    ("datetime(<event_time>, 'start of day') >= datetime(current_time, 'start of day','-1 day')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT_REL(DATEADD(DAY, -1, GETDATE()), 'start-of day')) = 1"),

    #############################################################################################################

    # Q: "... event/s occurred UNTIL 3 years *ago*"
    ("datetime(<event_time>) <= datetime(current_time, '-3 year')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT(DATEADD(YEAR, -3, GETDATE()))) = 1"),

    # Q: "... event/s occurred UNTIL 7 months *ago*"
    ("datetime(<event_time>) <= datetime(current_time, '-7 month')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT(DATEADD(MONTH, -7, GETDATE()))) = 1"),

    # Q: "... event/s occurred UNTIL 2 days *ago*"
    ("datetime(<event_time>) <= datetime(current_time, '-2 day')",
     "dbo.MEETS(<event_time>, dbo.TIME_POINT(DATEADD(DAY, -2, GETDATE()))) = 1"),

    #############################################################################################################

    # Q: "... event/s occurred SINCE 6 years *ago*"
    ("datetime(<event_time>) >= datetime(current_time, '-6 year')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT(DATEADD(YEAR, -6, GETDATE()))) = 1"),

    # Q: "... event/s occurred SINCE 2 months *ago*"
    ("datetime(<event_time>) >= datetime(current_time, '-2 month')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT(DATEADD(MONTH, -2, GETDATE()))) = 1"),

    # Q: "... event/s occurred SINCE 4 days *ago*"
    ("datetime(<event_time>) >= datetime(current_time, '-4 day')",
     "dbo.MET_BY(<event_time>, dbo.TIME_POINT(DATEADD(DAY, -4, GETDATE()))) = 1"),

    #############################################################################################################
    #                       Time filter type - 'within':                                                        #
    #############################################################################################################

    # Q: "... instances of 2 event/s occurring WITHIN *the same* year"
    ("datetime(<event_time_1>, 'start of year') = datetime(<event_time_2>, 'start of year')",
     "dbo.DURING(<event_time_1>, dbo.TIME_INTERVAL_REL(<event_time_2>, 'year')) = 1"),

    # Q: "... instances of 2 event/s occurring WITHIN *the same* month"
    ("datetime(<event_time_1>, 'start of month') = datetime(<event_time_2>, 'start of month')",
     "dbo.DURING(<event_time_1>, dbo.TIME_INTERVAL_REL(<event_time_2>, 'month')) = 1"),

    # Q: "... instances of 2 event/s occurring WITHIN *the same* day"
    ("datetime(<event_time_1>, 'start of day')= datetime(<event_time_2>, 'start of day')",
     "dbo.DURING(<event_time_1>, dbo.TIME_INTERVAL_REL(<event_time_2>, 'day')) = 1"),

    # Q: "... instances of 2 event/s occurring AT *the same* time"
    ("datetime(<event_time_1>) = datetime(<event_time_2>)",
     "dbo.DURING(<event_time_1>, dbo.TIME_POINT(<event_time_2>)) = 1")
]
def relative_replacer(match):
    """
        To be used with relative_regex, for:

        'datetime(<datetime>, '[start/end] of [year/month/day]', '[+/-]<num> [year/month/day]')
        <op>
        datetime(<datetime>, '[start/end] of [year/month/day]', '[+/-]<num> [year/month/day]')'

        'datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')
        <op>
        datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')'
    """
    (lhs_datetime, lhs_start_end, lhs_start_end_of, lhs_dt_modify_val, lhs_dt_modify_unit,
     op,
     rhs_datetime, rhs_start_end, rhs_start_end_of, rhs_dt_modify_val, rhs_dt_modify_unit) = \
        relative_extract_parts(match)

    # datetime(<datetime1>, 's/e of y/m/d', +/-n y/m/d) <op> datetime(<datetime2>, 's/e of y/m/d', '+/-n y/m/d')
    # optional:             ^___________ ^  ^________^                             ^____________^  ^__________^
    if lhs_datetime is not None and rhs_datetime is not None:

        # datetime(<datetime1> ...) <op> datetime(<datetime2> ... '{rhs_dt_modify_val} {rhs_dt_modify_unit}')
        # modification in case of:                                ^_______________ NON-empty ______________^
        if rhs_dt_modify_val is not None and int(rhs_dt_modify_val) != 0 and rhs_dt_modify_unit is not None:
            rhs_datetime = f"DATEADD({rhs_dt_modify_unit}, {rhs_dt_modify_val}, {rhs_datetime})"

        # datetime(<datetime1>, 'start of {ymd}') <op> datetime(<datetime2>, 'start of {ymd}', '{rhs_dt_modify_val} {ymd}')
        # optional:                                                                            ^_________________________^
        # (*) same:                        ^__^                                         ^__^                         ^__^
        if lhs_dt_modify_val is None and lhs_dt_modify_unit is None and \
                lhs_start_end == 'start' and lhs_start_end_of is not None and \
                rhs_start_end == 'start' and rhs_start_end_of is not None and \
                lhs_start_end_of == rhs_start_end_of and True:
            ymd = lhs_start_end_of

            # (*) {ymd} should be same in all 3 cases:
            if rhs_dt_modify_unit is not None and rhs_dt_modify_unit != ymd:
                raise ValueError(f"relative_replace: unknown pattern matched, match = [{match.group(0)}]")

            if op == '=':
                return f"dbo.DURING({lhs_datetime}, dbo.TIME_INTERVAL_REL({rhs_datetime}, '{ymd}')) = 1"
            if op == '<=':
                return f"dbo.MEETS({lhs_datetime}, dbo.TIME_POINT_REL({rhs_datetime}, 'start-of {ymd}')) = 1"
            if op == '>=':
                return f"dbo.MET_BY({lhs_datetime}, dbo.TIME_POINT_REL({rhs_datetime}, 'start-of {ymd}')) = 1"

        # datetime(<datetime1>) <op> datetime(<datetime2>, '{rhs_dt_modify_val} {lhs_dt_modify_unit}')
        # optional:                                        ^________________________________________^
        if lhs_start_end is None and lhs_start_end_of is None and lhs_dt_modify_val is None and lhs_dt_modify_unit is None and \
                rhs_start_end is None and rhs_start_end_of is None:
            if op == '=':
                return f"dbo.DURING({lhs_datetime}, dbo.TIME_POINT({rhs_datetime})) = 1"
            if op == '<=':
                return f"dbo.MEETS({lhs_datetime}, dbo.TIME_POINT({rhs_datetime})) = 1"
            if op == '>=':
                return f"dbo.MET_BY({lhs_datetime}, dbo.TIME_POINT({rhs_datetime})) = 1"

    raise ValueError(f"relative_replace: unknown pattern matched, match = [{match.group(0)}]")

def relative_extract_parts(match):
    lhs = match.group('lhs_rel')  # datetime(...)
    op = match.group('op_rel')  # <op>
    rhs = match.group('rhs_rel')  # datetime(...)

    lhs_datetime, lhs_start_end, lhs_start_end_of, lhs_dt_modify_val, lhs_dt_modify_unit = \
        datetime_clause_extract_parts(lhs)

    rhs_datetime, rhs_start_end, rhs_start_end_of, rhs_dt_modify_val, rhs_dt_modify_unit = \
        datetime_clause_extract_parts(rhs)

    return (lhs_datetime, lhs_start_end, lhs_start_end_of, lhs_dt_modify_val, lhs_dt_modify_unit,
            op,
            rhs_datetime, rhs_start_end, rhs_start_end_of, rhs_dt_modify_val, rhs_dt_modify_unit)

def datetime_clause_extract_parts(dt_clause):
    # datetime(<datetime>, '[start/end] of [year/month/day]', '[+/-]<num> [year/month/day]')
    datetime_regex = r"datetime\s*\(\s*(?P<datetime>[^,]+)\s*(,\s*'(?P<start_end>[\w]+)\s*of\s*(?P<start_end_of>[\w]+)'\s*)?(,\s*'(?P<dt_modify_val>[+-]?\d+)\s+(?P<dt_modify_unit>\w+)'\s*)?\)"  # ! (?P<datetime>[^,]+)
    capture_groups = get_capture_groups_matches(datetime_regex, func_name_translate(dt_clause))

    datetime = capture_groups['datetime']  # TODO...
    start_end = capture_groups['start_end']  # '[start/end]' (of) ...
    start_end_of = capture_groups['start_end_of']  # ... '[year/month/day]'
    dt_modify_val = capture_groups['dt_modify_val']  # '[+/-]<num>' ...
    dt_modify_unit = capture_groups['dt_modify_unit']  # ... '[year/month/day]')

    return datetime, start_end, start_end_of, dt_modify_val, dt_modify_unit

def func_name_translate(text: str) -> str:
    """
    Translates function names from SQLite to T-SQL, BEFORE calling sqlglot.
    """
    regex_to_replacer_map = {
        'current_time': 'GETDATE()'
    }
    return match_and_replace(text, list(regex_to_replacer_map.items()), [re.IGNORECASE])


# -----------------------------------------------------
#        Translation of MIXED time expressions:
# -----------------------------------------------------
# datetime(...) <op> datetime(...) AND strftime(...) <op> ...
mix_regex = fr'{relative_regex}\s*(AND|and)\s*{absolute_regex}'
mix_tests = [
    # Q: "... event/s occurred IN 3/*last* year"
    ("datetime(<event_time>, 'start of year') = datetime(current_time, 'start of year', '-1 year') AND "
     "strftime('%m',<event_time>) = '3'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(DATEADD(YEAR, -1, GETDATE())), 3, NULL)) = 1"),

    # Q: "... event/s occurred IN 3/*this* year"
    ("datetime(<event_time>, 'start of year') = datetime(current_time, 'start of year', '-0 year') AND "  # <- the '-0' thing is kinda weird
     "strftime('%m',<event_time>) = '3'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(GETDATE()), 3, NULL)) = 1"),

    ####################################################################################

    # Q: "... event/s occurred ON 12/24/*last* year"
    ("datetime(<event_time>, 'start of year')= datetime(current_time, 'start of year','-1 year') AND "
     "strftime('%m-%d', <event_time>) = '12-24'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(DATEADD(YEAR, -1, GETDATE())), 12, 24)) = 1"),

    # Q: "... event/s occurred IN 12/24/*this* year"
    ("datetime(<event_time>, 'start of year')= datetime(current_time, 'start of year','-0 year') AND "
     "strftime('%m-%d', <event_time>) = '12-24'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(GETDATE()), 12, 24)) = 1"),

    ####################################################################################

    # Q: "... event/s occurred ON *last* month/24"
    ("datetime(<event_time>, 'start of month') = datetime(current_time, 'start of month', '-1 month') AND "
     "strftime('%d', <event_time>) = '24'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(DATEADD(MONTH, -1, GETDATE())), "
     "MONTH(DATEADD(MONTH, -1, GETDATE())), "
     "24)) = 1"),

    # Q: "... event/s occurred ON *this* month/24"
    ("datetime(<event_time>, 'start of month') = datetime(current_time, 'start of month', '-0 month') AND "
     "strftime('%d', <event_time>) = '24'",

     "dbo.DURING(<event_time>, dbo.TIME_INTERVAL_YMD(YEAR(GETDATE()), MONTH(GETDATE()), 24)) = 1"),
]
def mix_replacer(match):
    """
        To be used with mix_regex, for:

        '{relative_clause} AND {absolute_clause}':

        'datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')
         <op>
         datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')

         AND

         strftime('{format_1st}-{format_2nd}-{format_3rd}', <datetime>) <op> '{1st}-{2nd}-{3rd}''
    """

    (rel_lhs_datetime, rel_lhs_start_end, rel_lhs_start_end_of, rel_lhs_dt_modify_val, rel_lhs_dt_modify_unit,
     rel_op,
     rel_rhs_datetime, rel_rhs_start_end, rel_rhs_start_end_of, rel_rhs_dt_modify_val,
     rel_rhs_dt_modify_unit) = relative_extract_parts(match)

    (abs_lhs_format_1st, abs_lhs_format_2nd, abs_lhs_format_3rd, abs_lhs_datetime,
     abs_op,
     abs_rhs_1st, abs_rhs_2nd, abs_rhs_3rd) = absolute_extract_parts(match)

    # 'datetime(<datetime>, 'start of {ymd}') = datetime(<datetime>, 'start of {ymd}', '{dt_modify_val} {ymd}') AND ...'
    if rel_lhs_datetime is not None and rel_rhs_datetime is not None and \
            rel_lhs_dt_modify_val is None and rel_lhs_dt_modify_unit is None and \
            rel_lhs_start_end == 'start' and rel_rhs_start_end == 'start' and \
            rel_lhs_start_end_of == rel_rhs_start_end_of == rel_rhs_dt_modify_unit is not None and \
            rel_rhs_dt_modify_val is not None and \
            rel_op == '=':

        # datetime(...) <op> datetime(... '{dt_modify_val} {ymd}') AND strftime(...) <op> ... ;
        # modification in case of:         ^__NON-ZERO__^
        if int(rel_rhs_dt_modify_val) != 0:
            rel_rhs_datetime = f"DATEADD({rel_rhs_dt_modify_unit}, {rel_rhs_dt_modify_val}, {rel_rhs_datetime})"

        # 'datetime({dt}, 'start of {ymd}') <op> datetime(<datetime>, 'start of {ymd}', '{mod_val} {ymd}') AND
        # strftime(<format>, {dt}) <op> <dt_formatted>'
        if abs_lhs_format_1st is not None and abs_lhs_datetime == rel_lhs_datetime and abs_rhs_1st is not None:

            # datetime({dt}, 'start of {ymd}') <op> datetime(<datetime>, 'start of {ymd}', '{mod_val} {ymd}') AND
            # strftime('%m', {dt}) <op> '{month}'
            if abs_lhs_format_1st == 'm' and abs_lhs_format_2nd is None and abs_lhs_format_3rd is None and \
                    abs_rhs_2nd is None and abs_rhs_3rd is None:
                if abs_op == '=':
                    return f"dbo.DURING({abs_lhs_datetime}, dbo.TIME_INTERVAL_YMD(YEAR({rel_rhs_datetime}), {abs_rhs_1st}, NULL)) = 1"

            # datetime({dt}, 'start of {ymd}') <op> datetime(<datetime>, 'start of {ymd}', '{mod_val} {ymd}') AND
            # strftime('%m-%d', {dt}) <op> '{month}-{day}'
            if abs_lhs_format_1st == 'm' and abs_lhs_format_2nd == 'd' and abs_lhs_format_3rd is None and \
                    abs_rhs_2nd is not None and abs_rhs_3rd is None:
                if abs_op == '=':
                    return f"dbo.DURING({abs_lhs_datetime}, dbo.TIME_INTERVAL_YMD(YEAR({rel_rhs_datetime}), {abs_rhs_1st}, {abs_rhs_2nd})) = 1"

            # datetime({dt}, 'start of {ymd}') <op> datetime(<datetime>, 'start of {ymd}', '{mod_val} {ymd}') AND
            # strftime('%d', {dt}) = '{day}'
            if abs_lhs_format_1st == 'd' and abs_lhs_format_2nd is None and abs_lhs_format_3rd is None and \
                    abs_rhs_2nd is None and abs_rhs_3rd is None:
                if abs_op == '=':
                    return f"dbo.DURING({abs_lhs_datetime}, dbo.TIME_INTERVAL_YMD(YEAR({rel_rhs_datetime}), MONTH({rel_rhs_datetime}), {abs_rhs_1st})) = 1"

    raise ValueError(f"mix_replace: unknown pattern matched, match = [{match.group(0)}]")


# ---------------------------------------------------------
#        Translation of "BETWEEN" time expressions:
# ---------------------------------------------------------
# datetime(...) BETWEEN datetime(...) AND datetime(...)
between_regex = r'(?P<dt1>datetime\(.+?\))\s+(BETWEEN|between)\s+(?P<dt2>datetime\(.+?\))\s+(AND|and)\s+(?P<dt3>datetime\(.+?\))'  # [^)]+ -> .+?
between_tests = [
    # Q: "... 2 events occurred WITHIN 3 year"
    ("datetime(dt2) BETWEEN datetime(current_time) AND datetime(current_time, '+3 year')",
     "dbo.DURING(dt2, dbo.TIME_INTERVAL_REL(GETDATE(), 'within +3 year')) = 1"),

    # Q: "... 2 events occurred WITHIN 1 month"
    ("datetime(\"tbl2.col1\")    between datetime(\"tbl1.col3\")    AND   datetime(\"tbl1.col3\",   '+1 month')",
     "dbo.DURING(\"tbl2.col1\", dbo.TIME_INTERVAL_REL(\"tbl1.col3\", 'within +1 month')) = 1"),

    # Q: "... 2 events occurred WITHIN 4 day"
    ("datetime('dt-2')  BETWEEN   datetime('dt-1')   and    datetime('dt-1', '+4 day')",
     "dbo.DURING('dt-2', dbo.TIME_INTERVAL_REL('dt-1', 'within +4 day')) = 1")
]
def between_replacer(match):
    """
        To be used with between_regex, for:

        'datetime(...) BETWEEN datetime(...) AND datetime(...)':

        'datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')

        BETWEEN

        datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')

        AND

        datetime(<datetime>, '{start_end} of {start_end_of}', '{dt_modify_val} {dt_modify_unit}')'
    """

    dt1 = match.group('dt1')  # datetime(...)
    dt2 = match.group('dt2')  # datetime(...)
    dt3 = match.group('dt3')  # datetime(...)

    dt1_datetime, dt1_start_end, dt1_start_end_of, dt1_modify_val, dt1_modify_unit = datetime_clause_extract_parts(dt1)
    dt2_datetime, dt2_start_end, dt2_start_end_of, dt2_modify_val, dt2_modify_unit = datetime_clause_extract_parts(dt2)
    dt3_datetime, dt3_start_end, dt3_start_end_of, dt3_modify_val, dt3_modify_unit = datetime_clause_extract_parts(dt3)

    # "datetime(<dt2>) BETWEEN datetime(<dt1>) AND datetime(<dt1>, '{dt2_modify_val} {dt2_modify_unit}')"
    if dt1_start_end is None and dt1_start_end_of is None and dt1_modify_val is None and dt1_modify_unit is None and \
            dt2_start_end is None and dt2_start_end_of is None and dt2_modify_val is None and dt2_modify_unit is None and \
            dt3_start_end is None and dt3_start_end_of is None and dt3_modify_val is not None and dt3_modify_unit is not None and \
            dt1_datetime != dt2_datetime and dt2_datetime == dt3_datetime:
        return f"dbo.DURING({dt1_datetime}, dbo.TIME_INTERVAL_REL({dt2_datetime}, 'within {dt3_modify_val} {dt3_modify_unit}')) = 1"

    raise ValueError(f"between_replace: unknown pattern matched, match = [{match.group(0)}]")


# -----------------------------------------------------------
#     Translation of JULIAN-DAY-DIFFERENCE time expressions:
# -----------------------------------------------------------
# strftime(...) <op> strftime(...)
date_diff_regex = r"(?P<lhs>strftime\s*\(.+?\))\s*(?P<op>[=<>+\-\w]+)\s*(?P<rhs>strftime\s*\(.+?\))"
date_diff_tests = [
    # Q: ... number of days SINCE event
    ("strftime('%J',current_time) - strftime('%J', icustays.intime)",
     "DATEDIFFF(DAY, icustays.intime, GETDATE())")
]
def date_diff_replacer(match):
    """
        To be used with date_diff_regex, for:
        strftime(...) <op> strftime(...)
    """
    lhs = match.group('lhs')  # strftime(...)
    op = match.group('op')  # <op>
    rhs = match.group('rhs')  # strftime(...)

    to_format_1st, to_format_2nd, to_format_3rd, to_datetime = strftime_clause_extract_parts(lhs)
    from_format_1st, from_format_2nd, from_format_3rd, from_datetime = strftime_clause_extract_parts(rhs)

    # strftime('%J', <datetime>) - strftime('%J', <datetime>)
    if to_format_1st == 'J' and to_format_2nd is None and to_format_3rd is None and to_datetime is not None and \
            op == '-' and \
            from_format_1st == 'J' and from_format_2nd is None and from_format_3rd is None and from_datetime is not None:

        # 'DATEDIFFF' should be 'DATEDIFF'. It's a workaround for sqlglot's weird behavior, see 'finalize_translation'.
        return f'DATEDIFFF(DAY, {from_datetime}, {to_datetime})'

    raise ValueError(f"date_diff_replace: unknown pattern matched, match = [{match.group(0)}]")


# ----------------------------------------------------------------------------------------------------
#  Translation of select-compare expressions (wrapping with 'IIF', a fix to make it work in T-SQL):
# ----------------------------------------------------------------------------------------------------
# "^select (<lhs>) <op> (<rhs>);":

# Old versions:
# r"^(SELECT|select)\s*(?P<comparison>\(.+\)\s*[<>=]\s*\(.+\))$"
# ^(SELECT)\s* (?P<lhs>\(.+\))\s*(?P<op>[<>=])\s*(?P<rhs>\(.+\))$ ==> (?P<rhs_prf>\(((?!FROM).)*)\s(?P<rhs_sff>FROM.+\))

select_compare_fix_regex = r"^(SELECT)\s*(?P<lhs_prf>\(((?!FROM).)*)\s(?P<lhs_sff>FROM.+\))\s*(?P<op>[<>=])\s*(?P<rhs_prf>\(((?!FROM).)*)\s(?P<rhs_sff>FROM.+\))$"
select_compare_fix_tests = [
    ("SELECT (SELECT TOP 1 chartevents.valuenum FROM chartevents) > (SELECT TOP 1 labevents.valuenum FROM labevents)",
     "SELECT IIF(lhs.val > rhs.val, 1, 0) FROM (SELECT TOP 1 chartevents.valuenum AS val FROM chartevents) AS lhs CROSS APPLY (SELECT TOP 1 labevents.valuenum AS val FROM labevents) AS rhs"),

    ("SELECT (SELECT TOP 1 chartevents.valuenum FROM chartevents WHERE chartevents.stay_id IN (SELECT TOP 1 icustays.stay_id FROM icustays WHERE icustays.hadm_id IN (SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 10021118) AND NOT icustays.outtime IS NULL ORDER BY icustays.intime ASC) AND chartevents.itemid IN (SELECT d_items.itemid FROM d_items WHERE d_items.label = 'arterial blood pressure diastolic' AND d_items.linksto = 'chartevents') ORDER BY chartevents.charttime DESC) > (SELECT chartevents.valuenum FROM chartevents WHERE chartevents.stay_id IN (SELECT TOP 1 icustays.stay_id FROM icustays WHERE icustays.hadm_id IN (SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 10021118) AND NOT icustays.outtime IS NULL ORDER BY icustays.intime ASC) AND chartevents.itemid IN (SELECT d_items.itemid FROM d_items WHERE d_items.label = 'arterial blood pressure diastolic' AND d_items.linksto = 'chartevents') ORDER BY chartevents.charttime DESC OFFSET 1 ROWS FETCH FIRST 1 ROWS ONLY)",
      "SELECT IIF(lhs.val > rhs.val, 1, 0) FROM (SELECT TOP 1 chartevents.valuenum AS val FROM chartevents WHERE chartevents.stay_id IN (SELECT TOP 1 icustays.stay_id FROM icustays WHERE icustays.hadm_id IN (SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 10021118) AND NOT icustays.outtime IS NULL ORDER BY icustays.intime ASC) AND chartevents.itemid IN (SELECT d_items.itemid FROM d_items WHERE d_items.label = 'arterial blood pressure diastolic' AND d_items.linksto = 'chartevents') ORDER BY chartevents.charttime DESC) AS lhs CROSS APPLY (SELECT chartevents.valuenum AS val FROM chartevents WHERE chartevents.stay_id IN (SELECT TOP 1 icustays.stay_id FROM icustays WHERE icustays.hadm_id IN (SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 10021118) AND NOT icustays.outtime IS NULL ORDER BY icustays.intime ASC) AND chartevents.itemid IN (SELECT d_items.itemid FROM d_items WHERE d_items.label = 'arterial blood pressure diastolic' AND d_items.linksto = 'chartevents') ORDER BY chartevents.charttime DESC OFFSET 1 ROWS FETCH FIRST 1 ROWS ONLY) AS rhs")
]

# "^select <lhs> <op> <rhs> from ... ;":
select_compare_fix_2_regex = r"^(SELECT|select)\s*(?P<comparison>((?!FROM).)*?\s*[<>=]\s*((?!FROM).)*?)\s*(FROM|from)"
select_compare_fix_2_tests = [
    ("SELECT COUNT(*) = 0 FROM prescriptions WHERE",
     "SELECT IIF(COUNT(*) = 0, 1, 0) FROM prescriptions WHERE")
]

# alternatively:
# select_compare_fix_2_regex_a = r"^(SELECT)\s* (?P<lhs>\(.+\))\s*(?P<op>[<>=])\s*(?P<rhs>\(.+\))$"
# select_compare_fix_2_regex_b = r"(?P<rhs_prf>\(((?!FROM).)*)\s(?P<rhs_sff>FROM.+\))"

def select_compare_replacer(match):
    """
        To be used with select_compare_regex, for:
        "select (<lhs>) <op> (<rhs>);"
    """
    lhs_prf = match.group('lhs_prf')  #
    lhs_sff = match.group('lhs_sff')  #
    op = match.group('op')  #
    rhs_prf = match.group('rhs_prf')  #
    rhs_sff = match.group('rhs_sff')  #
    # TODO: check if 5 elements above are not None?

    return (f'SELECT IIF(lhs.val {op} rhs.val, 1, 0) FROM '
            f'{lhs_prf} AS val {lhs_sff} AS lhs '
            f'CROSS APPLY '
            f'{rhs_prf} AS val {rhs_sff} AS rhs')

def select_compare_2_replacer(match):
    """
        To be used with select_compare_2_regex, for:
        "select <lhs> <op> <rhs> from ... ;"
    """
    comparison = match.group('comparison')  # (...) > (...)
    return f'SELECT IIF({comparison}, 1, 0) FROM'


translation_tuples = [
    # regex                      replacer_function          test_pairs                  test_name:
    (select_compare_fix_2_regex, select_compare_2_replacer, select_compare_fix_2_tests, 'select_compare_fix_2'),
    (select_compare_fix_regex,   select_compare_replacer,   select_compare_fix_tests,   'select_compare_fix'),
    (mix_regex,                  mix_replacer,              mix_tests,                  'mix'),
    (relative_regex,             relative_replacer,         relative_tests,             'relative'),
    (absolute_regex,             absolute_replacer,         absolute_tests,             'absolute'),
    (between_regex,              between_replacer,          between_tests,              'between'),
    (exact_absolute_regex,       exact_absolute_replacer,   exact_absolute_tests,       'exact_absolute'),
    (date_diff_regex,            date_diff_replacer,        date_diff_tests,            'date_diff')
]

post_translation_tuples = [
    # only for run_translation_tests(...)
    # regex              replacer_function      test_pairs,         test_name)
    (orderby_mod_regex,  orderby_mod_replacer,  orderby_mod_tests,  'orderby_mod'),  # for translation validation
    (subquery_fix_regex, subquery_fix_replacer, subquery_fix_tests, 'subquery_fix')  # for finalize_translation(...)
]

# =====================================================================================================================

def main():
    """
    Test mode
    """
    run_translation_tests()


if __name__ == "__main__":
    main()
