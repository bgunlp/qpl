import re

import asyncio
from tqdm.asyncio import tqdm as tqdm_async

from dataset_creation.ehrsql2024.util import (
    json_load, json_list_write, get_progress_bar, file_remove, match_and_replace, MimicIvConnectionManager, dictify,
    sql_pretty_print, ep_pretty_print, cte_pretty_print, file_write, json_file_create_pretty_print
)
from dataset_creation.ehrsql2024.constants import (
    tsql_qpl_cte_ans_ok_filepath, tsql_qpl_pp_ok_filepath, tsql_ep_ok_filepath, tsql_qpl_cte_ans_eq_filepath,
    tsql_qpl_cte_ans_uneq_filepath, cte_ans_missing_distinct_filepath, cte_ans_redundant_columns_filepath,
    tsql_qpl_cte_ok_filepath, tsql_qpl_cte_ans_err_filepath, tsql_qpl_cte_err_filepath
)
from dataset_creation.ehrsql2024.qpl_creation import (
    get_from_json, tsql_finlize_for_ep_fetching, get_execution_plan, _eps_to_qpls_pp
)
from dataset_creation.ehrsql2024.dataset_translation import is_equal_answers, tsql_modify_for_validation

# =========================================================
#               CTE validation:
# =========================================================
def dataset_validate_cte_answers():
    """
    Validate the answers of the CTEs against the answers of the corresponding T-SQLs they translated from
    """
    ok_eq = []
    ok_uneq = []
    missing_distinct = []

    for cte_data in json_load(tsql_qpl_cte_ans_ok_filepath):
        if is_equal_answers(cte_data['cte_final_ans'], cte_data['tsql_final_ans']):
            ok_eq.append(cte_data)
        else:
            ok_uneq.append(cte_data)

        if ('DISTINCT' in cte_data['tsql']) and ('DISTINCT' not in cte_data['cte']):
            missing_distinct.append(cte_data)

    print(f"\n{len(ok_eq)} CTE answers equal to expected")
    json_list_write(ok_eq, tsql_qpl_cte_ans_eq_filepath)

    print(f"\n{len(ok_uneq)} CTE answers different than expected")
    json_list_write(ok_uneq, tsql_qpl_cte_ans_uneq_filepath)

    """
    The fact that DISTINCT clause exist in TSQL but not in QPL (thus CTE) not NECESSARILY means a problem, as the 
    execution plans may take in account unique index or other optimization issues, but SOMETIMES - it DOES indicate a
    semantic inequivalence between TSQL and QPL:
    """
    print(f"\nAdditional debug info: {len(missing_distinct)} cases of CTE/QPL lack DISTINCT clause")
    json_list_write(missing_distinct, cte_ans_missing_distinct_filepath)

    print()
    json_file_create_pretty_print(tsql_qpl_cte_ans_eq_filepath)  # for debug purposes

    file_remove(tsql_qpl_cte_ans_ok_filepath)

def fix_qpls_with_redundant_cols_in_cte_ans():
    print('\n')

    # Calculate indexes of relevant columns for CTE answers containing redundant columns:
    relevant_cols_data = []
    redundant_cols_data = json_load(cte_ans_redundant_columns_filepath)
    for redundant_col_data in redundant_cols_data:
        tsql_ans_1st_cell = redundant_col_data['tsql_final_ans'][0][0]
        cte_ans_1st_row = redundant_col_data['cte_final_ans'][0]
        if tsql_ans_1st_cell in cte_ans_1st_row:
            cte_ans_relevant_col_idx = cte_ans_1st_row.index(tsql_ans_1st_cell)
            relevant_cols_data.append({
                'id': redundant_col_data['id'],
                'cte_ans_relevant_col_idx': cte_ans_relevant_col_idx,
            })
    relevant_cols_data_dct = dictify(relevant_cols_data)

    # Fix QPLs which CTE answer contain redundant columns:
    last_outs_regex = r'Output \[ (?P<outs>[\w,\s]+) \]$'
    qpls_data = json_load(tsql_qpl_pp_ok_filepath)
    qpls_data_fixed = []
    fixed = 0
    for qpl_data in get_progress_bar(qpls_data, "Fixing QPLs with redundant columns in CTE answer"):
        if qpl_data['id'] in relevant_cols_data_dct:
            if m := re.search(last_outs_regex, qpl_data['qpl']):
                outs = m.group('outs')
                outs_lst = [out.strip() for out in outs.split(',')]

                relevant_col_data = relevant_cols_data_dct[qpl_data['id']]
                relevant_col_idx = relevant_col_data['cte_ans_relevant_col_idx']
                out_relevant_col = outs_lst[relevant_col_idx]

                qpl_fixed = match_and_replace(qpl_data['qpl'], [
                    (rf'Output \[ {outs} \]$',
                     rf'Output [ {out_relevant_col} ]')
                ])
                qpl_data['qpl'] = qpl_fixed
                fixed += 1

        qpls_data_fixed.append(qpl_data)

    # Write fixed QPLs data:
    print(f"\n{fixed} QPLs fixed")
    json_list_write(qpls_data_fixed, tsql_qpl_pp_ok_filepath)

def dataset_add_cte_answers(is_concurrent=True, is_re_run=False):
    print('\n')

    if is_re_run:
        desc_suffix = ' for fixed CTEs (re-run)'
    else:
        desc_suffix = ''

    description = f'Adding CTE answers{desc_suffix}'

    ctes_data = json_load(tsql_qpl_cte_ok_filepath)
    ok, err, redundant_cols = _get_cte_answers_concurrent(ctes_data, description) if is_concurrent else _get_cte_answers(ctes_data, description)

    print(f"\n{len(ok)} successfully added CTE answers{desc_suffix}")
    json_list_write(ok, tsql_qpl_cte_ans_ok_filepath)

    print(f"\n{len(err)} failed attempts to add CTE answer{desc_suffix}")
    json_list_write(err, tsql_qpl_cte_ans_err_filepath)

    """
    The validation process of CTE answers accounts for answers containing more than 1 column,
    below information is collected for documentation and further debug of this phenomena:
    """
    print(f"\nAdditional debug info: {len(redundant_cols)} cases of CTE answers{desc_suffix} containing more than 1 column")
    json_list_write(redundant_cols, cte_ans_redundant_columns_filepath)

    if is_re_run:
        file_remove(tsql_qpl_cte_ok_filepath)

def _get_cte_answers(ctes_data, description):
    print()
    ok = []
    err = []
    redundant_cols = []

    with MimicIvConnectionManager() as conn:
        for cte_data in get_progress_bar(ctes_data, description):
            cte_final = tsql_modify_for_validation(cte_data['cte'])
            cte_data['cte_final'] = cte_final
            try:
                cte_data['cte_final_ans'] = conn.exec_fetch(cte_final)
                ok.append(cte_data)
                if len(cte_data['cte_final_ans']) > 0 and len(cte_data['cte_final_ans'][0]) != 1:
                    redundant_cols.append({'id': cte_data['id'], 'tsql_final_ans': cte_data['tsql_final_ans'], 'cte_final_ans': cte_data['cte_final_ans']})

            except Exception as e:
                cte_data['cte_final_ans'] = str(e)
                err.append(cte_data)

    return ok, err, redundant_cols

def _get_cte_answers_concurrent(ctes_data, description, async_workers=5):
    return asyncio.run(dataset_add_cte_answers_async(ctes_data, description, async_workers))

async def dataset_add_cte_answers_async(ctes_data, description, async_workers):
    ans_ok_q = asyncio.Queue()
    ans_err_q = asyncio.Queue()
    redundant_cols_q = asyncio.Queue()

    pbar = tqdm_async(total=len(ctes_data), desc=f'{description} [async_workers={async_workers}]')

    # Fill "producer" async queue with CTEs:
    ctes_q = asyncio.Queue()
    for cte_data in ctes_data:
        ctes_q.put_nowait(cte_data)

    # Create and run a pull of async "consumers":
    tasks = []
    for i in range(async_workers):
        tasks.append(
            asyncio.create_task(
                add_cte_ans_worker(ctes_q, ans_ok_q, ans_err_q, redundant_cols_q, pbar, i)))

    # Wait for all work to finish:
    await ctes_q.join()
    pbar.close()

    # Wait for all consumers to stop:
    for task in tasks:
        task.cancel()
    await asyncio.gather(*tasks, return_exceptions=True)

    # Retrieving results:
    ok = []
    err = []
    redundant_cols = []

    while not ans_ok_q.empty():
        ok.append(ans_ok_q.get_nowait())
    while not ans_err_q.empty():
        err.append(ans_err_q.get_nowait())
    while not redundant_cols_q.empty():
        redundant_cols.append(redundant_cols_q.get_nowait())

    return ok, err, redundant_cols

async def add_cte_ans_worker(ctes_q, ans_ok_q, ans_err_q, redundant_cols_q, pbar, worker_id):
    """
    Consumes CTEs and produces CTE answers
    """
    while True:
        cte_data = await ctes_q.get()
        cte_final = tsql_modify_for_validation(cte_data['cte'])
        cte_data['cte_final'] = cte_final
        with MimicIvConnectionManager() as conn:
            try:
                cte_data['cte_final_ans'] = await asyncio.to_thread(conn.exec_fetch, cte_final)
                await ans_ok_q.put(cte_data)

                if len(cte_data['cte_final_ans']) > 0 and len(cte_data['cte_final_ans'][0]) != 1:
                    await redundant_cols_q.put({'id': cte_data['id'],
                                                'tsql_final_ans': cte_data['tsql_final_ans'],
                                                'cte_final_ans': cte_data['cte_final_ans']})

            except Exception as e:
                cte_data['cte_final_ans'] = str(e)
                await ans_err_q.put(cte_data)

            finally:
                ctes_q.task_done()
                pbar.update(1)

# =========================================================
#               CTE creation:
# =========================================================
def dataset_add_ctes(is_re_run=False):
    print('\n')
    ok = []
    err = []

    if is_re_run:
        desc_suffix = ' from fixed QPLs (re-run)'
    else:
        desc_suffix = ''

    for qpl_data in get_progress_bar(json_load(tsql_qpl_pp_ok_filepath), f'Adding CTEs{desc_suffix}'):
        try:
            qpl_data['cte'] = _qpl_pp_to_cte(qpl_data['qpl'])
        except Exception as e:
            qpl_data['cte'] = str(e)

        if qpl_data['cte'].startswith('WITH '):
            ok.append(qpl_data)
        else:
            err.append(qpl_data)

    print(f"\n{len(ok)} successfully created CTEs{desc_suffix}")
    json_list_write(ok, tsql_qpl_cte_ok_filepath)

    print(f"\n{len(err)} failed attempts to create CTE{desc_suffix}")
    json_list_write(err, tsql_qpl_cte_err_filepath)

def _qpl_pp_to_cte(qpl_pp: str) -> str:
    from dataset_creation.qpl_to_cte import flat_qpl_to_cte

    db_id, qpl = qpl_pp.split(" | ")
    result = flat_qpl_to_cte(qpl.split(" ; "), db_id)
    result = re.sub('mimic_iv', 'mimic_iv.dbo', result)

    return result

# #############################################
#                   CTE tests
# #############################################

def tsql_ids_to_ctes(tsql_ids: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_data = get_from_json(tsql_ids, tsql_ep_ok_filepath)
    tsqls = [tsql_data['tsql'] for tsql_data in tsqls_data]
    tsqls_to_ctes(tsqls, filename_pref)

def tsqls_to_ctes(tsqls: list[str], filename_pref='anonymous'):
    """
    For testing
    """
    tsqls_final = [tsql_finlize_for_ep_fetching(tsql) for tsql in tsqls]
    eps = [get_execution_plan(tsql) for tsql in tsqls_final]
    qpls_pp = _eps_to_qpls_pp(eps)
    ctes = [_qpl_pp_to_cte(qpl_pp) for qpl_pp in qpls_pp]

    sqls_eps_qpls_pp = [str(idx)               + ":\n\n" +
                        sql_pretty_print(tsql) + "\n\n\n\n" +
                        cte_pretty_print(cte)  + "\n\n\n\n" +
                        ep_pretty_print(ep)
                        for idx, (tsql, ep, qpl_pp, cte) in enumerate(zip(tsqls, eps, qpls_pp, ctes))]

    file_write(f"\n\n{'='*150}\n\n".join(sqls_eps_qpls_pp), f"out_for_testing/{filename_pref}_cte.txt")

