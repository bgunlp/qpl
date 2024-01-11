import argparse
import hashlib
import json
from pathlib import Path
from typing import List

import pymssql
import regex as re
from tqdm.auto import tqdm

from evaluation import Evaluator, Schema, get_schema, get_sql

AFTER_FROM_KEYWORDS = ["where", "order", "group"]
HASH_JOIN_OPT = "OPTION (HASH JOIN, ORDER GROUP)"
MERGE_JOIN_OPT = "OPTION (MERGE JOIN, ORDER GROUP)"
LOOP_JOIN_OPT = "OPTION (LOOP JOIN, ORDER GROUP)"
JOIN_OPT = HASH_JOIN_OPT

MANUAL_PLANS = {
    "16efa1d00b88ef4622bb7345796502ef8e42ddb5fdc95f2e66d3ed8ca53f44cf": """<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.539" Build="15.0.4298.1"><BatchSequence><Batch><Statements><StmtSimple StatementCompId="1" StatementEstRows="233" StatementId="1" StatementOptmLevel="FULL" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="150" StatementSubTreeCost="0.00951574" StatementText="SELECT count ( * ) AS Count_Star , max ( Percentage ) AS Max_Percentage FROM world_1.countrylanguage WHERE LANGUAGE = 'Spanish' GROUP BY CountryCode" StatementType="SELECT" QueryHash="0xBC8EE4E5B9590B8E" QueryPlanHash="0x50CA25EB729EC09A" RetrievedFromCache="true" SecurityPolicyApplied="false"><StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true"/><QueryPlan NonParallelPlanReason="MaxDOPSetToOne" CachedPlanSize="24" CompileTime="7" CompileCPU="7" CompileMemory="240"><MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0" GrantedMemory="0" MaxUsedMemory="0"/><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="328070" EstimatedPagesCached="328070" EstimatedAvailableDegreeOfParallelism="1" MaxCompileMemory="33353072"/><OptimizerStatsUsage><StatisticsInfo Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Statistics="[PK__countryl__51A65408B367069D]" ModificationCount="0" SamplingPercent="100" LastUpdate="2023-06-11T02:20:48.95"/></OptimizerStatsUsage><RelOp AvgRowSize="15" EstimateCPU="0" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="233" LogicalOp="Compute Scalar" NodeId="0" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="0.00951574"><OutputList><ColumnReference Column="Expr1002"/><ColumnReference Column="Expr1003"/></OutputList><ComputeScalar><DefinedValues><DefinedValue><ColumnReference Column="Expr1002"/><ScalarOperator ScalarString="CONVERT_IMPLICIT(int,[Expr1007],0)"><Convert DataType="int" Style="0" Implicit="true"><ScalarOperator><Identifier><ColumnReference Column="Expr1007"/></Identifier></ScalarOperator></Convert></ScalarOperator></DefinedValue></DefinedValues><RelOp AvgRowSize="15" EstimateCPU="0.0007069" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="233" LogicalOp="Aggregate" NodeId="1" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00951574"><OutputList><ColumnReference Column="Expr1003"/><ColumnReference Column="Expr1007"/></OutputList><StreamAggregate><DefinedValues><DefinedValue><ColumnReference Column="Expr1007"/><ScalarOperator ScalarString="Count(*)"><Aggregate AggType="countstar" Distinct="false"/></ScalarOperator></DefinedValue><DefinedValue><ColumnReference Column="Expr1003"/><ScalarOperator ScalarString="MAX([spider].[world_1].[countrylanguage].[Percentage])"><Aggregate AggType="MAX" Distinct="false"><ScalarOperator><Identifier><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></Identifier></ScalarOperator></Aggregate></ScalarOperator></DefinedValue></DefinedValues><GroupBy><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/></GroupBy><RelOp AvgRowSize="14" EstimateCPU="0.0012394" EstimateIO="0.00756944" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="984" EstimatedRowsRead="984" LogicalOp="Clustered Index Scan" NodeId="2" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00880884" TableCardinality="984"><OutputList><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></OutputList><IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/></DefinedValue><DefinedValue><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></DefinedValue></DefinedValues><Object Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Index="[PK__countryl__51A65408B367069D]" IndexKind="Clustered" Storage="RowStore"/><Predicate><ScalarOperator ScalarString="[spider].[world_1].[countrylanguage].[Language]='Spanish'"><Compare CompareOp="EQ"><ScalarOperator><Identifier><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Language"/></Identifier></ScalarOperator><ScalarOperator><Const ConstValue="'Spanish'"/></ScalarOperator></Compare></ScalarOperator></Predicate></IndexScan></RelOp></StreamAggregate></RelOp></ComputeScalar></RelOp></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>""",
    "a1fd3e36763de62d67634d2be00cc30e68e90ed8288550458734eb39e0156e48": """<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.539" Build="15.0.4298.1"><BatchSequence><Batch><Statements><StmtSimple StatementCompId="1" StatementEstRows="233" StatementId="1" StatementOptmLevel="FULL" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="150" StatementSubTreeCost="0.00951574" StatementText="SELECT count ( * ) AS Count_Star , max ( Percentage ) AS Max_Percentage FROM world_1.countrylanguage WHERE LANGUAGE = 'Spanish' GROUP BY CountryCode" StatementType="SELECT" QueryHash="0xBC8EE4E5B9590B8E" QueryPlanHash="0x50CA25EB729EC09A" RetrievedFromCache="true" SecurityPolicyApplied="false"><StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true"/><QueryPlan NonParallelPlanReason="MaxDOPSetToOne" CachedPlanSize="24" CompileTime="7" CompileCPU="7" CompileMemory="240"><MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0" GrantedMemory="0" MaxUsedMemory="0"/><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="328070" EstimatedPagesCached="328070" EstimatedAvailableDegreeOfParallelism="1" MaxCompileMemory="33353072"/><OptimizerStatsUsage><StatisticsInfo Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Statistics="[PK__countryl__51A65408B367069D]" ModificationCount="0" SamplingPercent="100" LastUpdate="2023-06-11T02:20:48.95"/></OptimizerStatsUsage><RelOp AvgRowSize="15" EstimateCPU="0" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="233" LogicalOp="Compute Scalar" NodeId="0" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="0.00951574"><OutputList><ColumnReference Column="Expr1002"/><ColumnReference Column="Expr1003"/></OutputList><ComputeScalar><DefinedValues><DefinedValue><ColumnReference Column="Expr1002"/><ScalarOperator ScalarString="CONVERT_IMPLICIT(int,[Expr1007],0)"><Convert DataType="int" Style="0" Implicit="true"><ScalarOperator><Identifier><ColumnReference Column="Expr1007"/></Identifier></ScalarOperator></Convert></ScalarOperator></DefinedValue></DefinedValues><RelOp AvgRowSize="15" EstimateCPU="0.0007069" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="233" LogicalOp="Aggregate" NodeId="1" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00951574"><OutputList><ColumnReference Column="Expr1003"/><ColumnReference Column="Expr1007"/></OutputList><StreamAggregate><DefinedValues><DefinedValue><ColumnReference Column="Expr1007"/><ScalarOperator ScalarString="Count(*)"><Aggregate AggType="countstar" Distinct="false"/></ScalarOperator></DefinedValue><DefinedValue><ColumnReference Column="Expr1003"/><ScalarOperator ScalarString="MAX([spider].[world_1].[countrylanguage].[Percentage])"><Aggregate AggType="MAX" Distinct="false"><ScalarOperator><Identifier><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></Identifier></ScalarOperator></Aggregate></ScalarOperator></DefinedValue></DefinedValues><GroupBy><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/></GroupBy><RelOp AvgRowSize="14" EstimateCPU="0.0012394" EstimateIO="0.00756944" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="984" EstimatedRowsRead="984" LogicalOp="Clustered Index Scan" NodeId="2" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00880884" TableCardinality="984"><OutputList><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></OutputList><IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="CountryCode"/></DefinedValue><DefinedValue><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Percentage"/></DefinedValue></DefinedValues><Object Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Index="[PK__countryl__51A65408B367069D]" IndexKind="Clustered" Storage="RowStore"/><Predicate><ScalarOperator ScalarString="[spider].[world_1].[countrylanguage].[Language]='Spanish'"><Compare CompareOp="EQ"><ScalarOperator><Identifier><ColumnReference Database="[spider]" Schema="[world_1]" Table="[countrylanguage]" Column="Language"/></Identifier></ScalarOperator><ScalarOperator><Const ConstValue="'Spanish'"/></ScalarOperator></Compare></ScalarOperator></Predicate></IndexScan></RelOp></StreamAggregate></RelOp></ComputeScalar></RelOp></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>""",
}


def add_execution_plan(
    split: list, tables: dict, cursor: pymssql.Cursor, spider_path: Path
) -> list:
    with open("./manual-queries.json") as f:
        manual_fixes = {x["id"]: x for x in json.load(f)}

    instances = []
    for instance in tqdm(split):
        db_id = instance["db_id"]
        question = (  # Remove unicode special quotes
            instance["question"]
            .replace("\u2018", "'")
            .replace("\u2019", "'")
            .replace("\u201c", "'")
            .replace("\u201d", "'")
            .strip()
        )

        try:
            difficulty = Evaluator().eval_hardness(
                get_sql(
                    Schema(
                        get_schema(spider_path / "database" / db_id / f"{db_id}.sqlite")
                    ),
                    instance["query"],
                )
            )
        except KeyError:
            difficulty = "unknown"
        instance_id = hashlib.sha256(
            bytes(f"{db_id}|{question}|{instance['query']}", "utf-8")
        ).hexdigest()

        instance["id"] = instance_id
        instance["question"] = question
        instance["difficulty"] = difficulty
        instance["query_original"] = instance["query"]

        if instance_id in manual_fixes:
            fix = manual_fixes[instance_id]
            new_query = fix["query"]
            cursor.execute(new_query)
            ep_xml = cursor.fetchone()[0]
            instance["question"] = fix["question"] if "question" in fix else question
            instance["query"] = new_query
            instance["ep"] = ep_xml
            instances.append(instance)
            continue

        table = tables[db_id]
        query_tokens = instance["query_toks"]
        query_tokens = add_forcescans(query_tokens)
        lowercase_query = instance["query"].lower()

        if "like" in query_tokens or "LIKE" in query_tokens:
            query_tokens = add_correct_like_pattern_to_tokens(
                instance["query"], query_tokens
            )
        if "group by" in lowercase_query:
            query_tokens = copy_columns_from_select_to_groupby(query_tokens)
        if "select distinct" in lowercase_query and "order by" in lowercase_query:
            query_tokens = copy_orderby_to_select_distinct(query_tokens)
        if "limit" in lowercase_query:
            query_tokens = convert_limit_to_top(query_tokens)
        if "join" in lowercase_query:
            # NOTE: Fun SQLite fact: no condition on JOIN is a CROSS JOIN
            if re.search(r"join (\w|\s)+ where", lowercase_query):
                query_tokens = convert_to_cross_join(query_tokens)
        if contains_agg(lowercase_query):
            query_tokens = add_agg_alias(query_tokens)

        query_tokens = ["'" if t in ("``", "''") else t for t in query_tokens]
        query_tokens = add_schema_name_to_tables(db_id, query_tokens, table)
        new_query = re.sub(r"'\s*([^']+)\s+'", r"'\1'", " ".join(query_tokens))
        new_query = re.sub(r'"([^"]+)"', r"'\1'", new_query)
        if instance_id in MANUAL_PLANS:
            instance["query"] = new_query
            instance["ep"] = MANUAL_PLANS[instance_id]
            instances.append(instance)
            continue

        new_query = f"{new_query.replace(';', '')} {JOIN_OPT}"
        for sqs in re.findall(r"'([^']*)'", new_query):
            if m := re.search(r"\( (\w+) \)", sqs):
                s = m.groups()[0]
                new_query = new_query.replace(sqs, sqs.replace(f"( {s} )", f"({s})"))
            if " !" in sqs:
                new_query = new_query.replace(sqs, sqs.replace(" !", "!"))
            if " ?" in sqs:
                new_query = new_query.replace(sqs, sqs.replace(" ?", "?"))
        try:
            cursor.execute(new_query)
            ep_xml = cursor.fetchone()[0]
            instance["query"] = new_query
            instance["ep"] = ep_xml
            instances.append(instance)
        except pymssql.Error as e:
            msg = e.args[1].decode("utf-8")
            # NOTE:
            # This is a hack.
            # There are several cases of SELECT ... FROM (SELECT ... )
            # This doesn't work in SQL Server, unless the FROM gets an alias,
            # so I artificially add an alias at the end of the query.
            if (
                "Incorrect syntax near ')'." in msg
                or "Incorrect syntax near the keyword 'OPTION'." in msg
            ):
                if JOIN_OPT:
                    new_query = new_query[: -len(JOIN_OPT)] + " AS T10 " + JOIN_OPT
                else:
                    new_query = new_query + " AS T10"
                try:
                    cursor.execute(new_query)
                    ep_xml = cursor.fetchone()[0]
                    instance["query"] = new_query
                    instance["ep"] = ep_xml
                    instances.append(instance)
                except pymssql.Error:
                    instance["query"] = new_query
                    instance["ep"] = None
                    instances.append(instance)
            # NOTE:
            # Forcing the JOIN method doesn't work, remove it
            elif "Query processor could not produce a query plan" in msg:
                new_query = new_query.replace(JOIN_OPT, "")
                try:
                    cursor.execute(new_query)
                    ep_xml = cursor.fetchone()[0]
                    instance["query"] = new_query
                    instance["ep"] = ep_xml
                    instances.append(instance)
                except pymssql.Error:
                    raise NotImplementedError(f"{new_query = }")
            else:
                instance["query"] = new_query
                instance["ep"] = None
                instances.append(instance)
    return instances


def add_forcescans(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]

    new_query_tokens = []
    i = 0
    while i < len(query_tokens):
        if (
            lowercase_query_tokens[i] == "from"
            and i + 1 < len(query_tokens)
            and lowercase_query_tokens[i + 1] != "("
        ):
            if i + 2 < len(query_tokens) and lowercase_query_tokens[i + 2] == "as":
                new_query_tokens.extend(
                    [
                        "FROM",
                        query_tokens[i + 1],
                        "AS",
                        query_tokens[i + 3],
                        "WITH (FORCESCAN)",
                    ]
                )
                i += 4
            else:
                new_query_tokens.extend(
                    ["FROM", query_tokens[i + 1], "WITH (FORCESCAN)"]
                )
                i += 2
        elif i + 1 < len(query_tokens) and lowercase_query_tokens[i + 1] == "on":
            new_query_tokens.extend(
                [query_tokens[i], "WITH (FORCESCAN)", query_tokens[i + 1]]
            )
            i += 2
        else:
            new_query_tokens.append(query_tokens[i])
            i += 1
    return new_query_tokens


def add_correct_like_pattern_to_tokens(query, query_tokens):
    likes = re.findall(r"like ('|\")(.+?)('|\")", query, re.IGNORECASE)
    new_query_tokens = []
    i = 0
    while i < len(query_tokens):
        if query_tokens[i].lower() == "like":
            (_, like_pat, _) = likes.pop(0)
            new_query_tokens.append(query_tokens[i])
            new_query_tokens.append(f"'{like_pat}'")
            i += 2
            while i < len(query_tokens) and query_tokens[i] not in ("''", '"', "'"):
                i += 1
            i += 1
        else:
            new_query_tokens.append(query_tokens[i])
            i += 1
    return new_query_tokens


def convert_to_hash_join(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]

    new_query_tokens = []
    for t in lowercase_query_tokens:
        if t == "join":
            new_query_tokens.extend(["INNER", "HASH", "JOIN"])
        else:
            new_query_tokens.append(t)

    return new_query_tokens


def convert_to_cross_join(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]

    new_query_tokens = []
    for i, t in enumerate(lowercase_query_tokens):
        if t == "join":
            new_query_tokens.extend(["CROSS", "JOIN"])
        else:
            new_query_tokens.append(query_tokens[i])

    return new_query_tokens


def copy_orderby_to_select_distinct(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]
    order_idx = lowercase_query_tokens.index("order")
    for i in range(order_idx, -1, -1):
        if lowercase_query_tokens[i] == "distinct":
            distinct_idx = i
            break
    if lowercase_query_tokens[order_idx + 2] in ("sum", "avg", "count", "min", "max"):
        orderby_arg = query_tokens[
            order_idx + 2 : lowercase_query_tokens.index(")", order_idx + 2)
        ]
    else:
        orderby_arg = query_tokens[order_idx + 2]
    from_idx = lowercase_query_tokens.index("from")
    select_args = query_tokens[distinct_idx + 1 : from_idx]
    if type(orderby_arg) == list:
        query_tokens = (
            query_tokens[: distinct_idx + 1]
            + orderby_arg
            + [","]
            + query_tokens[distinct_idx + 1 :]
        )
    elif orderby_arg not in select_args:
        query_tokens = (
            query_tokens[: distinct_idx + 1]
            + [orderby_arg, ","]
            + query_tokens[distinct_idx + 1 :]
        )
    return query_tokens


def copy_columns_from_select_to_groupby(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]
    new_query_tokens = []
    i = 0
    while i < len(query_tokens):
        if lowercase_query_tokens[i] == "select":
            if lowercase_query_tokens[i + 1] == "distinct":
                select_idx = i + 1
                new_query_tokens.extend(query_tokens[i : i + 2])
                i += 2
            else:
                select_idx = i
                new_query_tokens.append(query_tokens[i])
                i += 1
        elif lowercase_query_tokens[i] == "from":
            select_args = [t for t in query_tokens[select_idx + 1 : i] if t != ","]
            lowercase_select_args = [t.lower() for t in select_args]
            for agg in ("sum", "avg", "count", "min", "max"):
                while agg in lowercase_select_args:
                    idx = lowercase_select_args.index(agg)
                    del select_args[idx : lowercase_select_args.index(")", idx) + 1]
                    lowercase_select_args = [t.lower() for t in select_args]
            new_query_tokens.append(query_tokens[i])
            i += 1
        elif (
            lowercase_query_tokens[i] == "group"
            and lowercase_query_tokens[i + 1] == "by"
        ):
            groupby_arg = query_tokens[i + 2]
            if groupby_arg not in select_args:
                select_args.append(groupby_arg)
            new_query_tokens.extend(query_tokens[i : i + 2])
            new_query_tokens.extend(" , ".join(select_args).split())
            i += 3
        else:
            new_query_tokens.append(query_tokens[i])
            i += 1
    return new_query_tokens


def add_schema_name_to_tables(db_id, query_tokens, table):
    new_query_tokens = []
    lowercase_table_names = [t.lower() for t in table["table_names_original"]]
    is_from = False
    for token in query_tokens:
        lower = token.lower()
        if lower == "from":
            is_from = True
        if is_from and lower in lowercase_table_names:
            new_query_tokens.append(f"{db_id}.{token}")
        else:
            new_query_tokens.append(token)
        if lower in AFTER_FROM_KEYWORDS:
            is_from = False
    return new_query_tokens


def convert_limit_to_top(query_tokens):
    lowercase_query_tokens = [t.lower() for t in query_tokens]
    while "limit" in lowercase_query_tokens:
        limit_idx = lowercase_query_tokens.index("limit")
        limit_arg = lowercase_query_tokens[limit_idx + 1]
        del query_tokens[limit_idx : limit_idx + 2]
        for i in range(limit_idx, -1, -1):
            if lowercase_query_tokens[i] == "select":
                select_idx = i
                break
        top = ["TOP", str(limit_arg)]  # , "WITH TIES"]
        if "distinct" in lowercase_query_tokens[select_idx:]:
            distinct_idx = lowercase_query_tokens.index("distinct")
            query_tokens = (
                query_tokens[: distinct_idx + 1]
                + top
                + query_tokens[distinct_idx + 1 :]
            )
        else:
            query_tokens = (
                query_tokens[: select_idx + 1] + top + query_tokens[select_idx + 1 :]
            )
        lowercase_query_tokens = [t.lower() for t in query_tokens]
    return query_tokens


def add_agg_alias(query_tokens: List[str]) -> List[str]:
    lowercase_query_tokens = [t.lower() for t in query_tokens]
    new_query_tokens = []
    inside_select = False
    i = 0
    while i < len(query_tokens):
        t = lowercase_query_tokens[i]
        if t == "select":
            inside_select = True
        if t == "from":
            inside_select = False
        if t in ("sum", "avg", "count", "min", "max") and inside_select:
            alias_args = []
            new_query_tokens.extend(query_tokens[i : i + 2])
            i += 2
            while lowercase_query_tokens[i] != ")":
                alias_args.append(query_tokens[i])
                new_query_tokens.append(query_tokens[i])
                i += 1
            new_query_tokens.append(")")
            alias = gen_alias(t, alias_args)
            new_query_tokens.extend(["AS", alias])
            i += 1
        else:
            new_query_tokens.append(query_tokens[i])
            i += 1
    return new_query_tokens


def gen_alias(agg: str, args: List[str]) -> str:
    if args == ["*"]:
        table = "Star"
    elif len(args) == 2:
        table = f"Dist_{args[1].replace('.', '_')}"
    else:
        components = args[0].split(".")
        table = components[1] if len(components) > 1 else components[0]
    return f"{agg.title()}_{table}"


def contains_agg(query: str) -> bool:
    for agg in ["avg", "min", "max", "count", "sum"]:
        if re.search(rf"{agg}\s*\(", query):
            return True
    return False


def is_runnable_sql(cursor: pymssql.Cursor, query: str) -> bool:
    try:
        cursor.execute(query)
        cursor.fetchall()
    except pymssql.Error:
        return False
    else:
        return True


def create_dataset(
    cursor: pymssql.Cursor,
    spider_path: Path,
    output_dir: Path,
) -> None:
    spider_train = spider_path / "train_spider.json"
    spider_dev = spider_path / "dev.json"
    spider_tables = spider_path / "tables.json"

    with open(spider_tables, mode="r", encoding="utf-8") as f:
        tables = json.load(f)
        tables = {table["db_id"]: table for table in tables}
    with open(spider_train, mode="r", encoding="utf-8") as f:
        train = json.load(f)
    with open(spider_dev, mode="r", encoding="utf-8") as f:
        dev = json.load(f)

    cursor.execute("SET SHOWPLAN_XML ON")

    new_train = add_execution_plan(train, tables, cursor, spider_path)
    new_dev = add_execution_plan(dev, tables, cursor, spider_path)

    cursor.execute("SET SHOWPLAN_XML OFF")

    keep_relevant_keys = lambda e: {
        "id": e["id"],
        "db_id": e["db_id"],
        "difficulty": e["difficulty"],
        "query": e["query"],
        "query_original": e["query_original"],
        "question": e["question"],
        "ep": e["ep"],
        "is_runnable": is_runnable_sql(cursor, e["query"]) if e["query"] else False,
    }

    with open(
        output_dir / "train_spider_with_ep.json", mode="w", encoding="utf-8"
    ) as f:
        json.dump(
            [keep_relevant_keys(e) for e in new_train],
            f,
            indent=2,
        )
    with open(output_dir / "dev_spider_with_ep.json", mode="w", encoding="utf-8") as f:
        json.dump(
            [keep_relevant_keys(e) for e in new_dev],
            f,
            indent=2,
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--spider-path", type=Path)
    parser.add_argument("-o", "--output-dir", type=Path)
    args = parser.parse_args()
    spider_path = args.spider_path
    output: Path = args.output_dir
    if not output.is_dir():
        print("Output path must be a directory")
        exit(1)
    output.mkdir(parents=True, exist_ok=True)
    conn = pymssql.connect("0.0.0.0", "SA", "Passw0rd!", autocommit=True)
    cursor = conn.cursor()
    cursor.execute("USE spider")
    cursor.execute("EXEC sp_updatestats")
    create_dataset(cursor, spider_path, output)
    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
