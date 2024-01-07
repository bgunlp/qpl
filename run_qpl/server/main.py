import json
from typing import List

import pandas as pd
import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from qpl_to_cte import flat_qpl_to_cte
from sqlalchemy import create_engine


class ValidationRequest(BaseModel):
    qpl: str


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

engine = create_engine(
    "mssql+pyodbc://SA:Passw0rd!@db/spider?driver=ODBC+Driver+17+for+SQL+Server",
)

with open("./schemas.json", encoding="utf-8") as f:
    schemas = json.load(f)
    for schema in schemas:
        res = requests.post("http://parser:8081/schema", json=schema)
        if res.status_code != 200:
            raise ValueError(f"Oops, couldn't register schema: {schema}")


@app.post("/validate")
async def validate_qpl(req: ValidationRequest):
    res = requests.post("http://parser:8081/validate", json={"qpl": req.qpl}).json()
    return res["tag"] == "valid"


@app.post("/{db_id}/qpl")
def qpl(db_id: str, qpl: List[str]):
    try:
        cte = flat_qpl_to_cte(qpl, db_id)
    except Exception as e:
        return {"error": e.args[0]}

    try:
        df = pd.read_sql(cte, engine)
    except Exception as e:
        return {"error": e.args[0]}
    df_json = df.to_dict(orient="records")
    return {"cte": cte, "result": df_json}
