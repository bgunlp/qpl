import itertools
import json
from dataclasses import dataclass
from typing import List, Dict, Optional
from collections import Counter
import re

import yaml

SPACE = "<SPC>"
NEWLINE = " ; "

plat_qpl_pattern = re.compile("(#\d+) = ([^\[]*) \[( [^\[]* )\](.*) Output \[( .* )\]")
nested_plan_pattern = re.compile(f"( *(?:{SPACE})* *)(In: )?([^\[]*)(?:\[( [^\[]* )\])?(.*) Output \[( .* )\]")
spaces_pattern = re.compile("( *).*")

class QPLOP:
    def __init__(self, name, options, returns, children):
        self.name = name
        self.options = options
        self.returns = returns
        self.children: List[QPLOP] = children

    def __str__(self):
        res = ''
        if self.name == 'Scan':
            res += f"Scan"

        else:
            res = f"[ {', '.join([str(x) for x in self.children])} ] Into: {self.name}"

        for option in self.options:
            res += f" {option['name']} [ {' , '.join(option['args'])} ]"

        if len(self.returns) > 0:
            res += f" Output [ {' , '.join(self.returns)} ]"

        return res

    def __repr__(self, indent=0):
        spaces = '\t' * indent
        res = ''
        for c in self.children:
            res += (c.__repr__(indent+2) + '\n')

        if self.name == 'Scan':
            res += spaces + f"Scan"
        else:
            res += spaces + f"Into: {self.name}"

        for option in self.options:
            res += f" {option['name']} [ {' , '.join(option['args'])} ]"

        if len(self.returns) > 0:
            res += f" Output [ {' , '.join(self.returns)} ]"

        return res

    def get_action_counts(self):
        c = Counter([self.name])
        for child in self.children:
            c.update(child.get_action_counts())
        return c

def build_QPLOP_from_tree(tree):
    return QPLOP(name=tree['name'],
                 options=tree['options'],
                 returns=tree['returns'],
                 children=[build_QPLOP_from_tree(x) for x in tree["ins"]] if "ins" in tree else [])

@dataclass
class DataRow:
    question: str
    database: str
    schema: Dict[str, List[str]]
    tree: QPLOP
    execution_plan: str
    cte: str
    sql: str
    id: str


    def schema_to_string(self) -> str:
        tables_str = []
        for table, columns in self.schema.items():
            tables_str.append(f"{table}: {', '.join(columns)}")
        return '\n'.join(tables_str)

from dataclasses import dataclass
from typing import List, Dict, Optional
from collections import Counter

class FlatQplOp:
    def __init__(self, id, table, name, options, returns, children):
        self.id = id
        self.table = table
        self.name = name
        self.options = options
        self.returns = returns
        self.children: List[FlatQplOp] = children

    def __str__(self):
        children = ' , '.join([c.id for c in self.children]) if self.children else self.table
        options = f' { self.options}' if self.options else ''
        res = f'{self.id} = {self.name} [ {children} ]{options} Output [ {self.returns} ]'
        if len(self.children) >= 1:
            res = res.replace('B.', f'{self.children[0].id}.')
        if len(self.children) >= 2:
            res = res.replace('T.', f'{self.children[1].id}.')
        return res

    def get_descendants(self):
        descendants = {self.id: self}
        for c in self.children:
            descendants.update(c.get_descendants())
        return descendants

    def to_nested_str(self, indent: int = 0):
        result = ""
        indent_str = SPACE * indent + ("In: " if indent else "")
        result += indent_str
        result += self.name

        if self.table:
            result += f' [ {self.table} ]'
        if self.options:
            result += f' {self.options}'
        result += f" Output [ {self.returns} ]"

        for i, child in enumerate(self.children[::-1]):
            if i == 0:
                result = result.replace(child.id, 'T')
            elif i == 1:
                result = result.replace(child.id, 'B')
            result += f'{NEWLINE}{child.to_nested_str(indent + 1)}'

        return result

    def to_dict(self):
        result = dict()
        result['id'] = self.id
        result['operation'] = self.name
        if self.table:
            result['table'] = self.table
        if self.options:
            result['predicate'] = self.options
        result['output'] = self.returns
        if self.children:
            result['children'] = [c.to_dict() for c in self.children]
        return result

    def to_json(self):
        return json.dumps(self.to_dict(), indent=4)

    def to_yaml(self):
        res = yaml.dump(self.to_dict(), default_flow_style=False, sort_keys=False)
        lines = res.split("\n")
        new_lines = []
        for i, line in enumerate(lines):
            if len(line.strip()) == 0:
                continue
            m = spaces_pattern.match(line)
            spaces = len(m.group(1))
            new_lines.append(spaces * SPACE + line[spaces:])
        return NEWLINE.join(new_lines)

    def get_all_sub_trees(self):
        return [build_FlatQplOp_from_nested_plan(self.to_nested_str()),
                *itertools.chain.from_iterable([c.get_all_sub_trees() for c in self.children])]

    def __repr__(self):
        return ' ; '.join([str(c) for c in sorted(self.get_descendants().values(), key=lambda x: int(x.id[1:]))]).replace(", ", " , ")

    def get_action_counts(self):
        c = Counter([self.name])
        for child in self.children:
            c.update(child.get_action_counts())
        return c


def build_QPLOP_from_tree(tree) -> QPLOP:
    return QPLOP(name=tree['name'],
                 options=tree['options'],
                 returns=tree['returns'],
                 children=[build_QPLOP_from_tree(x) for x in tree["ins"]] if "ins" in tree else [])


def build_QPLOP_from_dict(qpl_dict: Dict, id=1) -> FlatQplOp:
    return FlatQplOp(
        id=qpl_dict.get('id'),
        table=qpl_dict.get('table'),
        name=qpl_dict.get('operation'),
        options=qpl_dict.get('predicate'),
        returns=qpl_dict.get('output'),
        children=[build_QPLOP_from_dict(c) for c in qpl_dict.get('children', [])]
    )

def build_QPLOP_from_json(qpl_json: str) -> FlatQplOp:
    return build_QPLOP_from_dict(json.loads(qpl_json))

def build_QPLOP_from_yaml(qpl_yaml: str) -> FlatQplOp:
    lines = qpl_yaml.split(NEWLINE)
    lines = [l.strip().replace(f"{SPACE} ", SPACE).replace(SPACE, " ") for l in lines]
    return build_QPLOP_from_dict(yaml.safe_load("\n".join(lines)))


def build_FlatQplOp(qpl: str) -> FlatQplOp:
    node_ids = {}
    lines = [x.strip() for x in qpl.split(' ; ')]
    node = None
    for line in lines:
        m = plat_qpl_pattern.match(line)
        id = m.group(1)
        op = m.group(2).strip()
        tbl_name = None
        tables = [x.strip() for x in m.group(3).split(',')]
        options = m.group(4).strip()
        return_str = m.group(5).strip()
        children = list()
        for table in tables:
            if table in node_ids:
                children.append(node_ids[table])
            else:
                tbl_name = table
        node = FlatQplOp(id, tbl_name, op, options, return_str, children)
        node_ids[id] = node
    return node

def build_FlatQplOp_from_nested_plan(plan: str):
    lines = plan.strip().split(NEWLINE)
    stack = []
    for i, line in enumerate(lines):
        id = f'#{len(lines) - i}'
        m = nested_plan_pattern.match(line)
        indent = len(m.group(1).strip().replace(SPACE, " "))
        if indent > 0:
            for _ in range(len(stack) - indent):
                stack.pop()
        op = m.group(3).strip()
        tbl_name = None
        options = []
        if op == 'Scan Table':
            tbl_name = m.group(4).strip()
        else:
            op_split = op.split()
            if len(op_split) > 1:
                op, options = op_split[0], [op_split[1].strip()]
            if m.group(4):
                options.append(f'[ {m.group(4).strip()} ]')
        options.append(m.group(5).strip())
        return_str = m.group(6).strip()
        children = list()
        node = FlatQplOp(id, tbl_name, op, ' '.join(options).strip(), return_str, children)

        if stack:
            parent = stack[-1]
            parent.children.insert(0, node)

        # Push the current node to the stack to make it the current parent
        stack.append(node)

    return stack[0]

@dataclass
class DataRow:
    question: str
    database: str
    schema: Dict[str, List[str]]
    tree: QPLOP
    execution_plan: str
    cte: str
    sql: str
    id: str


    def schema_to_string(self) -> str:
        tables_str = []
        for table, columns in self.schema.items():
            tables_str.append(f"{table}: {', '.join(columns)}")
        return '\n'.join(tables_str)


