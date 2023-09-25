import unittest

from validate_qpl import *

class TestSameRs(unittest.TestCase):

    def test_empty_input(self):
        grs = []
        prs = []
        qpl = ["Scan Table Test"]
        result = same_rs(grs, prs, qpl)
        self.assertEqual(result, True, "Empty inputs should be identical")

    def test_identical_results(self):
        grs = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
        prs = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
        qpl = ["Scan Table Test"]
        result = same_rs(grs, prs, qpl)
        self.assertEqual(result, True, "Identical results should return True")

    def test_different_results(self):
        grs = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
        prs = [{'id': 3, 'name': 'Charlie'}, {'id': 4, 'name': 'David'}]
        qpl = ["Scan Table Test"]
        result = same_rs(grs, prs, qpl)
        self.assertEqual(result, False, "Different results should return False")

    def test_partial_match(self):
        grs = [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]
        prs = [{'id': 1, 'name': 'Alice'}, {'id': 3, 'name': 'Charlie'}]
        qpl = ["Scan Table Test"]
        result = same_rs(grs, prs, qpl)
        self.assertEqual(result, False, "Partial match should return False")

    def test_different_column_names(self):
        grs = [{'id': 1, 'name': 'Alice'}]
        prs = [{'identifier': 1, 'name': 'Alice'}]
        qpl = ["Scan Table Test"]
        result = same_rs(grs, prs, qpl)
        self.assertEqual(result, True, "Different column names should be ignored as much as possible and return True")

if __name__ == '__main__':
    unittest.main()
