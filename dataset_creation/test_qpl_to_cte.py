import unittest

from qpl_to_cte import *
from sqlalchemy import create_engine
from run_queries import get_results

class TestFlatQplToCte(unittest.TestCase):

    def setUp(self):
        self.engine = create_engine(
            "mssql+pyodbc://SA:Passw0rd!@0.0.0.0/spider?driver=ODBC+Driver+17+for+SQL+Server"
        )

    def tearDown(self):
        self.engine.dispose()

    def test_group_by_no_output(self):
        qpl = [
            "#1 = Scan Table [ singer ] Output [ Name , Country , Age ]",
            "#2 = Aggregate [ #1 ] GroupBy [ Name , Country , Age ] Output [ countstar AS Count_Star ]"
        ]
        db_id = "concert_singer"
        cte = str(flat_qpl_to_cte(qpl, db_id))
        res = get_results(cte, self.engine)
        expected = [
            {'age': 52, 'count_star': 1, 'country': 'Netherlands', 'name': 'Joe Sharp'},
            {'age': 43, 'count_star': 1, 'country': 'France', 'name': 'John Nizinik'},
            {'age': 29, 'count_star': 1, 'country': 'France', 'name': 'Justin Brown'},
            {'age': 41, 'count_star': 1, 'country': 'France', 'name': 'Rose White'},
            {'age': 32, 'count_star': 1, 'country': 'United States', 'name': 'Timbaland'},
            {'age': 25, 'count_star': 1, 'country': 'France', 'name': 'Tribal King'}
        ]
        self.assertEqual(res, expected, "Group by columns should be returned in CTE")

    def test_group_by_few_columns(self):
        qpl = [
            "#1 = Scan Table [ singer ] Output [ Name , Country , Age ]",
            "#2 = Aggregate [ #1 ] GroupBy [ Name , Country , Age ] Output [ Name , countstar AS Count_Star ]"
        ]
        db_id = "concert_singer"
        cte = str(flat_qpl_to_cte(qpl, db_id))
        res = get_results(cte, self.engine)
        expected = [
            {'age': 52, 'count_star': 1, 'country': 'Netherlands', 'name': 'Joe Sharp'},
            {'age': 43, 'count_star': 1, 'country': 'France', 'name': 'John Nizinik'},
            {'age': 29, 'count_star': 1, 'country': 'France', 'name': 'Justin Brown'},
            {'age': 41, 'count_star': 1, 'country': 'France', 'name': 'Rose White'},
            {'age': 32, 'count_star': 1, 'country': 'United States', 'name': 'Timbaland'},
            {'age': 25, 'count_star': 1, 'country': 'France', 'name': 'Tribal King'}
        ]
        self.assertEqual(res, expected, "Group by columns should be returned in CTE")