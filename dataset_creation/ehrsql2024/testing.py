"""
Testing playground
"""
import dataset_creation.ehrsql2024.qpl_creation as qpl_cr
import dataset_creation.ehrsql2024.cte_creation as cte_cr

def main():
    tsqls_tmp = [
        """
        """,
    ]
    tsqls_temporal = [
        """
        SELECT admissions.dischtime
        FROM admissions
        WHERE dbo.MEETS(admissions.dischtime, dbo.TIME_INTERVAL(admissions.dischtime, admissions.dischtime)) = 1
          AND subject_id = 10004235
        """,  # 1. (does not appear in ehrsql2024-2024 dataset)

        """
        SELECT DATEDIFF(YEAR, admissions.dischtime, GETDATE())
        FROM admissions
        WHERE dbo.DURING(admissions.dischtime, dbo.TIME_INTERVAL_REL(DATEADD(YEAR, -1, GETDATE()), 'year')) = 1
        """,  # 2.

        """
        SELECT diagnoses_icd.icd_code
        FROM diagnoses_icd
        WHERE dbo.DURING(diagnoses_icd.charttime, dbo.TIME_INTERVAL_YMD(2100, NULL, NULL)) = 1
        """,  # 3.

        """
        SELECT DATEDIFF(MONTH, chartevents.charttime, GETDATE())
        FROM chartevents
        WHERE dbo.MET_BY(chartevents.charttime, dbo.TIME_POINT(DATEADD(MONTH, -5, GETDATE()))) = 1
        """,  # 4

        """
        SELECT admissions.dischtime
        FROM admissions
        WHERE dbo.MEETS(admissions.dischtime, dbo.TIME_POINT_REL(admissions.dischtime, 'start-of day')) = 1
          AND admissions.dischtime is not null
        """,  # 5. (does not appear in ehrsql2024-2024 dataset)

        """
        SELECT labevents.valuenum
        FROM labevents
        WHERE dbo.MET_BY(labevents.charttime, dbo.TIME_POINT_START_OF_YMD(2100, 05, NULL)) = 1

        """,  # 6.

        """
        SELECT diagnoses_icd.charttime -- icd_code
        FROM diagnoses_icd
        WHERE dbo.MEETS(diagnoses_icd.charttime,
                        dbo.TIME_POINT_YMDHMS(2100, 01, 10, 16, MONTH(dateadd(year, -1, getdate())), NULL)) =
              1
        """,  # 7.
    ]

    """ 
    Can copy EP from './out_for_testing/anonymous_EP.txt' into "ep" field in 'qpl/dataset_creation/output/tst1.json', 
    then manually run Scala (plantoqpl.scala), then observe output in 'qpl/dataset_creation/output/tst1_qpl.json': 
    """
    # qpl_cr.tsql_to_ep(tsqls_temporal[0])

    """ Can compare against files suffixed with '_G' (gold), or between themselves to observe the translations: """
    # qpl_cr.tsqls_to_qpls_raw(tsqls_temporal, '_TEST_TSQLs_to_QPLs_temporal')
    # qpl_cr.tsqls_to_qpls_pp(tsqls_temporal, '_TEST_TSQLs_to_QPLs_temporal')
    # cte_cr.tsqls_to_ctes(tsqls_temporal, '_TEST_TSQLs_to_QPLs_temporal')
    # ---------------------------------------------------------------------

    ids_tmp = [
        "10e5776d6866e2b43f77a084",
    ]
    ids_0 = [
        # Subtracting sub-queries:
        # "SELECT (SELECT...) - (SELECT...)"
        "5ae9eba9c11262b3bc8961b7",  # 0
        "150dcba6b064df151fc6eaf3",  # 1
        "922e1796a0883763c0252e8b",  # 2
        # "10e5776d6866e2b43f77a084 ",  # 3  # TODO: fix (few examples of this problem)
    ]
    ids_1 = [
        # Comparing sub-queries:
        # "SELECT IIF(lhs.val > rhs.val, 1, 0) FROM (SELECT...) AS lhs CROSS APPLY (SELECT...) AS rhs"
        "06ed0a3cc8ab3dc7839b7919",  # 0
        "0845eda9197d9666e0b3a017",  # 1
        "ac19aaffd02ad22588a7a6e7",  # 2
        "fd2b88c449aa3147d9ef22a9",  # 3
        # "7a1c80e590227785f1b6c6a6",  # 4  (additional working case)
        # "96a829af0978aeef2a29366b",  # 5  (additional working case)
    ]
    ids_2 = [
        "e366e701723a7868b82006d6",  # 0
        "f92a9715af7d181a656d4998",  # 1
        "9cd37fc842ad70310d54ee58",  # 2
        "b9c136c1e1d19649caabdeb4",  # 3
        "fc9243a5cde088d80aaae29a",  # 4
        "b3baba0d3d4a30996c8d7040",  # 5
        "068a6fbca2eb611746f77955",  # 6
        "10f5ecdf9123785c95f2bff6",  # 7
        "7b2e4a56a587f857df255484",  # 8
    ]

    """ Can compare against files suffixed with '_G' (gold), or between themselves to observe the translations: """
    # qpl_cr.tsql_ids_to_qpls_raw(ids_tmp, '_TEST_TSQL_IDs_to_QPLs_TMP')
    # qpl_cr.tsql_ids_to_qpls_pp(ids_tmp, '_TEST_TSQL_IDs_to_QPLs_TMP')
    # cte_cr.tsql_ids_to_ctes(ids_tmp, '_TEST_TSQL_IDs_to_QPLs_TMP')
    #
    # qpl_cr.tsql_ids_to_qpls_raw(ids_0, '_TEST_TSQL_IDs_to_QPLs_0')
    # qpl_cr.tsql_ids_to_qpls_raw(ids_1, '_TEST_TSQL_IDs_to_QPLs_1')
    # qpl_cr.tsql_ids_to_qpls_raw(ids_2, '_TEST_TSQL_IDs_to_QPLs_2')
    #
    # qpl_cr.tsql_ids_to_qpls_pp(ids_0, '_TEST_TSQL_IDs_to_QPLs_0')
    # qpl_cr.tsql_ids_to_qpls_pp(ids_1, '_TEST_TSQL_IDs_to_QPLs_1')
    # qpl_cr.tsql_ids_to_qpls_pp(ids_2, '_TEST_TSQL_IDs_to_QPLs_2')
    #
    # cte_cr.tsql_ids_to_ctes(ids_0, '_TEST_TSQL_IDs_to_QPLs_0')
    # cte_cr.tsql_ids_to_ctes(ids_1, '_TEST_TSQL_IDs_to_QPLs_1')
    # cte_cr.tsql_ids_to_ctes(ids_2, '_TEST_TSQL_IDs_to_QPLs_2')


if __name__ == "__main__":
    main()
