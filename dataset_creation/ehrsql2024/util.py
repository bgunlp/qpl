from tqdm.auto import tqdm

import re
import json
import pymssql

import sqlparse
import copy
import time
from functools import reduce

from typing import Any, Iterable
from collections.abc import Callable

import os
import errno


# ================================
#        Files I/O methods:
# ================================
def json_file_create_pretty_print(json_path: str) -> None:
    json_path_components = json_path.split('.')
    json_path_basename = json_path_components[0]
    json_path_extension = json_path_components[1]
    json_path_new = f'{json_path_basename}_pretty_print.{json_path_extension}'
    json_list_write(json_load(json_path), json_path_new, is_pretty_print_data=True)

def json_load(json_path):
    with open(json_path, mode="r", encoding="utf-8") as f:
        return json.load(f)

def json_list_write(lst, json_path, is_pretty_print_json=True, is_pretty_print_data=False, is_print_mssg=True):
    if len(lst) == 0:
        return False

    if is_print_mssg:
        print(f'Writing to [{json_path}]')

    if is_pretty_print_data:
        lst = [data_pretty_print(translated_data) for translated_data in
               get_progress_bar(lst, f'Creating pretty printing for elements in [{json_path}]')]

    obj_json_str = json.dumps(lst, indent=4 if is_pretty_print_json else None)

    if is_pretty_print_data:
        obj_json_str = match_and_replace(obj_json_str, [
            (r'\\n', r'\n'),
            (r'\\t', r'\t'),
            (r"},", r"},\n\n\n"),

            (r'"SELECT', r'\n"SELECT'),
            (r'"#1 =', r'\n"#1 ='),
            (r'"WITH', r'\n"WITH'),

            (r'"sqlite', r'\n\t\t"sqlite'),
            (r'"tsql', r'\n\t\t"tsql'),
            (r'"qpl', r'\n\t\t"qpl'),
            (r'"cte', r'\n\t\t"cte'),
        ])

    file_write(obj_json_str, json_path)
    return True

def file_read(json_path):
    with open(json_path, mode="r", encoding="utf-8") as f:
        return f.read()

def file_write(text, filepath):
    with open(filepath, mode="w", encoding="utf-8") as f:
        return f.write(text)

def file_remove(filepath, print_mssg=True):
    if print_mssg:
        print(f'\nDeleting [{filepath}]')
    try:
        os.remove(filepath)
    except OSError as e:
        if e.errno != errno.ENOENT:  # errno.ENOENT = no such file or directory
            raise  # re-raise exception if a different error occurred


# ================================
#        Pretty-printing methods:
# ================================
def data_pretty_print(data: dict[str, str]) -> dict[str, str]:
    data = copy.deepcopy(data)

    if 'sqlite' in data:
        data['sqlite'] = sql_pretty_print(data['sqlite'])

    if 'tsql' in data:
        data['tsql'] = sql_pretty_print(data['tsql'])

    if 'tsql_for_translation_validation' in data:
        data['tsql_for_translation_validation'] = sql_pretty_print(data['tsql_for_translation_validation'])

    if 'tsql_final' in data:
        data['tsql_final'] = sql_pretty_print(data['tsql_final'])

    if 'tsql_for_ep' in data:
        data['tsql_for_ep'] = sql_pretty_print(data['tsql_for_ep'])

    if 'qpl_raw' in data:
        data['qpl_raw'] = qpl_pretty_print(data['qpl_raw'])

    if 'qpl' in data:
        data['qpl'] = qpl_pretty_print(data['qpl'])

    if 'cte' in data:
        data['cte'] = cte_pretty_print(data['cte'])

    if 'cte_final' in data:
        data['cte_final'] = cte_pretty_print(data['cte_final'])

    return data

def sql_pretty_print(sql: str) -> str:
    return sqlparse.format(sql, reindent=True, keyword_case='upper')

def cte_pretty_print(cte: str) -> str:
    # return sqlglot.parse_one(cte).sql(pretty=True)
    cte_pp = sqlparse.format(cte, reindent=True, keyword_case='upper')
    cte_pp_final = match_and_replace(cte_pp, [
        (r"AS\n\s*\(",   r"AS (\n   "),
        (r"\),\n\s*",    r"\n  ),\n "),
        (r"WITH\s*",     r"WITH\n "),
        (r"\)\nSELECT",  r")\n\nSELECT"),
    ])
    return cte_pp_final

def ep_pretty_print(ep: str) -> str:
    import xml.dom.minidom

    dom = xml.dom.minidom.parseString(ep)
    dom = dom.getElementsByTagName('RelOp')[0]
    ep = dom.toprettyxml()

    return match_and_replace(ep, [
        (r'</.*',           ''),
        ('',                ''),   # WTF
        (r'\t+\n(\t+\n)+', r'\n'),
        (r'\n\n+',         r'\n'),

        (r'\[mimic_iv\]\.\[dbo\]\.',    r' '),
        (r'(Database|Schema)="\[\w+\]"', r''),
        (r'\[', r''),
        (r'\]', r''),
        (r'EstimateRows.*>', r'>'),
        (r'Ordered=.*>', r'>'),
        (r'Index=.*>', r'>'),
        (r'StartupExpression=.*>', r'>'),
        (r'<MemoryFractions.*\n\s*', r''),
        (r'&lt;', r' < '),
        (r'&gt;', r' > '),
    ])

def qpl_pretty_print(qpl: str) -> str:
    return match_and_replace(qpl, [
        (r'mimic_iv \| ', ''),
        ('; ',            r'\n'),
        ('] ',            r']\n\t '),
        ('AND ',          r'AND \n\t             ')
    ])


# ================================
#        Regex methods:
# ================================
def get_capture_groups_matches(regex: str, text: str) -> dict[str, str]:  # , ignore_case=False !!
    """
    @param regex: contains named capture groups.
    @param text: to apply @param regex on. should contain a single match.
    @return: Map between names of capture groups and parts of @param text matched by them.
    """
    matches = re.finditer(regex, text)
    match = next(matches, None)

    if match is None:
        raise ValueError(f'get_capture_groups_matches: len(matches) = 0 != 1')
    if next(matches, None) is not None:
        raise ValueError(f'get_capture_groups_matches: len(matches) > 1')

    return match.groupdict()  # TODO: value.lstrip() for each value

def match_and_replace(text: str | None,
                      regex_tuples: list[tuple[str, str | Callable[[re.Match], str]]],
                      flags: list[re.RegexFlag] = None) -> str | None:
    """
    match_and_replace(text, [(regex, replacer), ...])

    @param text: to apply regexes on, replacing matched parts.
    @param regex_tuples: of the form '[(regex, replacer, ...), ...]', where 'replacer' is a string or (Match)->str
                         method, to replace the parts of @param text that been matched by 'regex'.
    @param flags: optional regex flags.
    @return: @param text, after all '(regex, replacer)' tuples been applied on.
    """
    if text is None:
        return text

    flags = 0 if flags is None else reduce(lambda x, y: x | y, flags)

    for regex_tup in regex_tuples:
        regex, replacer = regex_tup[:2]
        text = re.sub(regex, replacer, text, flags=flags)

    return text


# ================================
#        DB connections:
# ================================
class MimicIvConnectionManager:
    def __init__(self):
        self.conn = None
        self.cursor = None

    def __enter__(self):
        self.conn = pymssql.connect("127.0.0.1", "SA", "Passw0rd!", autocommit=True)
        self.cursor = self.conn.cursor()
        self.cursor.execute("USE mimic_iv")
        return MimicIvCursorWrapper(self.cursor)

    def __exit__(self, exc_type, exc_value, exc_traceback):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()

class MimicIvCursorWrapper:
    def __init__(self, cursor):
        self.cursor = cursor

    def exec(self, sql):
        self.cursor.execute(sql)

    def exec_fetch(self, sql):
        self.exec(sql)
        rows = self.cursor.fetchall()
        return [[str(cell) if cell is not None else 'null' for cell in row] for row in rows]

    def exec_get_ep(self, sql):
        self.exec(sql)
        return self.cursor.fetchone()[0]


# ================================
#        Misc/aux methods:
# ================================
def dictify(lst: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    """
    :param lst: list of dicts containing 'id' key
    :return: dict (of dicts) mapping the 'id' key of each element of @lst to the element itself
    """
    return dict([(e['id'], e) for e in lst])

def get_progress_bar(lst: Iterable[Any], description: str = None) -> Any:
    progress_bar = tqdm(lst)
    if description is not None:
        progress_bar.set_description(description)
    return progress_bar

class RuntimeCountManager:
    def __init__(self, task_name=None):
        self.task_name = f" [{task_name}]" if task_name else ''
        self.time_start = None

    def __enter__(self):
        print(f"Starting{self.task_name}...")
        self.time_start = time.perf_counter()

    def __exit__(self, exc_type, exc_value, exc_traceback):
        if self.time_start:
            time_end = time.perf_counter()
            elapsed_time = time_end - self.time_start
            print(f"Finished{self.task_name} in [{elapsed_time:.1f}] seconds")
