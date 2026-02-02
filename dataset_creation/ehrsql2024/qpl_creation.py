import subprocess

from typing import Any

from dataset_creation.ehrsql2024.util import (
    json_load, json_list_write, get_progress_bar, file_remove, match_and_replace, MimicIvConnectionManager, dictify,
    RuntimeCountManager, sql_pretty_print, qpl_pretty_print, ep_pretty_print, file_write
)
from dataset_creation.ehrsql2024.constants import (
    tsql_qpl_raw_ok_filepath, tsql_qpl_pp_ok_filepath, tsql_qpl_pp_err_filepath, tsql_ep_ok_filepath, tsql_filepath,
    tsql_qpl_raw_err_filepath, ehrsql2024_path, tsql_ans_eq_filepath, tsql_ep_err_filepath
)
from dataset_creation.ehrsql2024.dataset_translation import tsql_post_process


# =========================================================
#               Post process QPLs:
# =========================================================
def dataset_add_qpls_pp():
    print('\n')
    ok = []
    err = []
    raw_qpls_data = json_load(tsql_qpl_raw_ok_filepath)
    for raw_qpl_data in get_progress_bar(raw_qpls_data, f'Adding post processed QPLs'):
        try:
            raw_qpl_data['qpl'] = _qpl_raw_to_qpl_pp(raw_qpl_data['qpl_raw'])
            ok.append(raw_qpl_data)
        except Exception as e:
            raw_qpl_data['qpl'] = str(e)
            err.append(raw_qpl_data)
        finally:
            del raw_qpl_data['qpl_raw']

    print(f"\n{len(ok)} successfully post-processed QPLs")
    json_list_write(ok, tsql_qpl_pp_ok_filepath)

    print(f"\n{len(err)} failed attempts to post-process QPL")
    json_list_write(err, tsql_qpl_pp_err_filepath)

def _qpl_raw_to_qpl_pp(qpl_raw: str) -> str:
    from dataset_creation.post_process_qpl import post_process

    db_id, qpl = qpl_raw.split(" | ")
    result = post_process(qpl.split(" ; "))
    qpl_pp = f"{db_id} | {' ; '.join(result)}"
    return qpl_pp


# =========================================================
#               Creating raw QPLs:
# =========================================================
def dataset_add_qpls_raw():
    print('\n')
    ok = []
    err = []

    tsqls_eps_data = json_load(tsql_ep_ok_filepath)  # for testing specific IDs: get_from_json(ids, tsql_ep_ok_filepath)
    eps_data_for_scala = [get_ep_scala_obj(ep_data) for ep_data in tsqls_eps_data]
    raw_qpls = eps_data_to_raw_qpls(eps_data_for_scala)
    raw_qpls_dict = dictify(raw_qpls)

    for ep_data in tsqls_eps_data:
        del ep_data['ep']
        qpl_raw = raw_qpls_dict[ep_data['id']]['qpl'] if ep_data['id'] in raw_qpls_dict else 'null'
        qpl_raw = qpl_raw.replace("inputevents.amount",  # due to inconsistency between versions of MIMIC-IV:
                                  "inputevents.totalamount")
        ep_data['qpl_raw'] = qpl_raw
        if (ep_data['qpl_raw']).startswith('mimic_iv |'):
            ok.append(ep_data)
        else:
            err.append(ep_data)

    print(f"\n{len(ok)} successfully created raw QPLs")
    json_list_write(ok, tsql_qpl_raw_ok_filepath)

    print(f"\n{len(err)} failed attempts to create raw QPL")
    json_list_write(err, tsql_qpl_raw_err_filepath)

def eps_data_to_raw_qpls(eps_data_for_scala: list[dict[str, str]]) -> list[dict[str, str]]:
    scala_in_json_path = fr"scala_in_TMP.json"
    scala_out_json_path = fr"scala_out_TMP.json"

    json_list_write(eps_data_for_scala, scala_in_json_path, is_print_mssg=False)
    run_ep_to_qpl_scala_cli(scala_in_json_path, scala_out_json_path)
    qpls_raw = json_load(scala_out_json_path)

    file_remove(scala_in_json_path, print_mssg=False)
    file_remove(scala_out_json_path, print_mssg=False)

    return qpls_raw

def run_ep_to_qpl_scala_cli(in_json_path, out_json_path):
    cmd = get_ep_to_qpl_scala_cli_command(in_json_path, out_json_path)
    with RuntimeCountManager(f"Execution plans to QPL (Scala CLI command)"):
        result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        return result.stdout
    else:
        raise Exception(str(result.returncode) + ':\n' + result.stderr + '\n\n' + result.stdout)

def get_ep_to_qpl_scala_cli_command(in_json_path: str, out_json_path: str) -> list[str]:
    return [
        "scala-cli",
        "run",
        r"..\mssql-execution-plans-to-qpl",
        "--",
        "-s",
        ehrsql2024_path,
        "-i",
        in_json_path,
        "-o",
        out_json_path
    ]

def get_ep_scala_obj(ep_obj: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": ep_obj['id'],
        "db_id": "mimic_iv",
        "difficulty": "easy",
        "query": ep_obj['tsql'],
        "query_original": ep_obj['sqlite'],
        "question": ep_obj['question'],
        "ep": ep_obj['ep'],
        "is_runnable": True
    }

# =========================================================
#               Fetching execution plans:
# =========================================================
def dataset_add_eps():
    print('\n')
    ok = []
    err = []
    tsqls_data = json_load(tsql_ans_eq_filepath)
    with MimicIvConnectionManager() as conn:
        conn.exec("EXEC sp_updatestats")
        # conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 1")  # not sure if it has an effect
        conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF")
        conn.exec("SET SHOWPLAN_XML ON")

        for tsql_data in get_progress_bar(tsqls_data, f'Adding execution plans'):
            tsql_for_ep = tsql_finlize_for_ep_fetching(tsql_data['tsql'])
            tsql_data['tsql_for_ep'] = tsql_for_ep
            try:
                ep_xml = conn.exec_get_ep(tsql_for_ep)
                tsql_data['ep'] = ep_xml
                ok.append(tsql_data)
            except Exception as e:
                tsql_data['ep'] = str(e)
                err.append(tsql_data)

        conn.exec("SET SHOWPLAN_XML OFF")
        conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = ON")
        # conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0")

    print(f"\n{len(ok)} successfully fetched execution plans")
    json_list_write(ok, tsql_ep_ok_filepath)

    print(f"\n{len(err)} failed attempts to fetch execution plan")
    json_list_write(err, tsql_ep_err_filepath)

    file_remove(tsql_ans_eq_filepath)

def tsql_finlize_for_ep_fetching(tsql: str) -> str:
    def rep(match):
        gd = match.groupdict()
        lhs = gd["lhs"]
        rhs = gd["rhs"]

        def _rep(_m):
            _gd = _m.groupdict()
            return f"{_gd['prf']} as val {_gd['frm']}"

        _p = r"(?P<prf>^\(SELECT (TOP 1 |SUM\()?\w+\.\w+\)?) (?P<frm>FROM.*\)$)"
        lhs = match_and_replace(lhs, [
            (_p, _rep),
        ])
        rhs = match_and_replace(rhs, [
            (_p, _rep),
        ])

        return f"SELECT rhs.val - lhs.val FROM {rhs} as lhs CROSS APPLY {lhs} as rhs"

    tsql_pp = tsql_post_process(tsql)

    p = r"^SELECT (?P<lhs>\(SELECT (TOP 1 |SUM\()?\w+\.\w+\)? FROM.*\))\s+\-\s+(?P<rhs>\(SELECT (TOP 1 |SUM\()?\w+\.\w+\)? FROM.*\))$"
    tsql_final = match_and_replace(tsql_pp, [
        (p, rep),
    ])

    tsql_final = match_and_replace(tsql_final, [
        (r"(FROM|JOIN) \w+ ", lambda m: f"{m.group(0)}WITH (FORCESCAN) "),
        (r"lhs.val > rhs.val", f"rhs.val < lhs.val"),
        (r"lhs.val < rhs.val", f"rhs.val > lhs.val"),
    ])

    hints = "OPTION (HASH JOIN, ORDER GROUP)"
    if (("CROSS APPLY" in tsql_final) or
            tsql_final.startswith("SELECT TOP 1 T1.starttime") or
            tsql_final.startswith("SELECT (SELECT COUNT_BIG(DISTINCT T1.subject_id)")):
        hints = "OPTION (ORDER GROUP)"

    tsql_final = rf"{tsql_final} {hints}"
    return tsql_final

def get_execution_plan(tsql: str) -> str:
    """
    For debug
    """
    with MimicIvConnectionManager() as conn:
        conn.exec("EXEC sp_updatestats")
        conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF")
        conn.exec("SET SHOWPLAN_XML ON")

        ep_xml = conn.exec_get_ep(tsql)

        conn.exec("SET SHOWPLAN_XML OFF")
        conn.exec("ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = ON")

    return ep_xml

# =========================================================
#               QPL tests:
# =========================================================
def tsql_ids_to_qpls_pp(tsql_ids: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_data = get_from_json(tsql_ids, tsql_filepath)
    tsqls = [tsql_data['tsql'] for tsql_data in tsqls_data]
    tsqls_to_qpls_pp(tsqls, filename_pref)

def tsql_ids_to_qpls_raw(tsql_ids: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_data = get_from_json(tsql_ids, tsql_filepath)
    tsqls = [tsql_data['tsql'] for tsql_data in tsqls_data]
    tsqls_to_qpls_raw(tsqls, filename_pref)

def get_from_json(ids: list[str], json_filepath: str) -> list[dict[str, str]]:
    """
        For testing.
        Fetches elements from JSON file corresponding to given ids.
    """
    data_dict = dictify(json_load(json_filepath))
    return [data_dict[_id] for _id in ids if _id in data_dict]

def tsqls_to_qpls_pp(tsqls: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_final = [tsql_finlize_for_ep_fetching(tsql) for tsql in tsqls]
    eps = [get_execution_plan(tsql) for tsql in tsqls_final]
    qpls_pp = _eps_to_qpls_pp(eps)

    sqls_eps_qpls_pp_ppr = [str(idx)                 + ":\n\n" +
                            sql_pretty_print(tsql)   + "\n\n\n\n" +
                            qpl_pretty_print(qpl_pp) + "\n\n\n\n" +
                            ep_pretty_print(ep)
                            for idx, (tsql, ep, qpl_pp) in enumerate(zip(tsqls, eps, qpls_pp))]

    file_write(f"\n\n{'='*150}\n\n".join(sqls_eps_qpls_pp_ppr), f"out_for_testing/{filename_pref}_pp.txt")

def tsqls_to_qpls_raw(tsqls: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_final = [tsql_finlize_for_ep_fetching(tsql) for tsql in tsqls]
    eps = [get_execution_plan(tsql) for tsql in tsqls_final]
    qpls_raw = _eps_to_qpls_raw(eps)

    sqls_eps_qpls_raw_ppr = [str(idx)                  + ":\n\n" +
                             sql_pretty_print(tsql)    + "\n\n\n\n" +
                             qpl_pretty_print(qpl_raw) + "\n\n\n\n" +
                             ep_pretty_print(ep)
                             for idx, (tsql, ep, qpl_raw) in enumerate(zip(tsqls, eps, qpls_raw))]

    file_write(f"\n\n{'='*150}\n\n".join(sqls_eps_qpls_raw_ppr), f"out_for_testing/{filename_pref}_raw.txt")

def _eps_to_qpls_pp(eps: list[str]) -> list[str]:
    """
    For testing
    """
    qpls_raw = _eps_to_qpls_raw(eps)
    qpls_pp = [_qpl_raw_to_qpl_pp(qpl_raw) for qpl_raw in qpls_raw]
    return qpls_pp

def _eps_to_qpls_raw(eps: list[str]) -> list[str]:
    """
    For testing
    """
    eps_data_for_scala = [get_mock_ep_scala_obj(ep) for ep in eps]
    raw_qpls_from_scala = eps_data_to_raw_qpls(eps_data_for_scala)
    qpls_raw = [raw_qpl_data['qpl'] for raw_qpl_data in raw_qpls_from_scala]
    return qpls_raw

def get_mock_ep_scala_obj(ep: str) -> dict[str, str]:
    """
    For testing
    """
    return {
        "id": 'mock_id',
        "db_id": "mimic_iv",
        "difficulty": "easy",
        "query": 'mock_sql',
        "query_original": 'mock_sql',
        "question": 'mock_question',
        "ep": ep,
        "is_runnable": True
    }

def tsql_to_ep(tsql: str, output_filename_prefix='anonymous'):
    """
    For testing
    """
    tsql_final = tsql_finlize_for_ep_fetching(tsql)
    ep = get_execution_plan(tsql_final)
    json_list_write(ep, f"out_for_testing/{output_filename_prefix}_EP.txt")   #


