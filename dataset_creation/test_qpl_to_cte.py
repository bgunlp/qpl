import unittest

from qpl_to_cte import *

class TestFlatQplToCte(unittest.TestCase):

    def test_group_by_all_columns(self):
        qpl = [
            "#1 = Scan Table [ singer ] Output [ Name , Country , Age ]",
            "#2 = Aggregate [ #1 ] GroupBy [ Name , Country , Age ] Output [ countstar AS Count_Star ]"
        ]
        db_id = "concert_singer"
        res = str(flat_qpl_to_cte(qpl, db_id))
        expected = \
'WITH Scan_1 AS ( SELECT Name, Country, Age FROM concert_singer.singer ), ' + \
 'Aggregate_2 AS ( SELECT Name, Country, Age, COUNT(*) AS Count_Star FROM Scan_1 GROUP BY Name , ' + \
 'Country , Age ) SELECT * FROM Aggregate_2'
        self.assertEqual(res, expected, "Group by columns should be returned in CTE")