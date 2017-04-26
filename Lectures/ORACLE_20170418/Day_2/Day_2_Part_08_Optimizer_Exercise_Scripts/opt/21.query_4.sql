@alter.session.sql

SELECT  /*+ monitor */
        d_month, d_year, s_nation,
        SUM(lo_quantity) lo_quantity,
        SUM(lo_revenue) lo_revenue,
        SUM(lo_supplycost) lo_supplycost
        FROM lineorder
                JOIN date_dim   ON lo_orderdate = d_datekey
                JOIN part       ON lo_partkey = p_partkey
                JOIN supplier   ON lo_suppkey = s_suppkey
        WHERE   d_year = 1994
        AND     s_region in ('ASIA')
        AND     s_nation in ('CHINA')
        AND     s_city in ('CHINA    1',
                           'CHINA    2',
                           'CHINA    3',
                           'CHINA    4',
                           'CHINA    5',
                           'CHINA    6',
                           'CHINA    7',
                           'CHINA    8',
                           'CHINA    9')
        AND     p_mfgr in ('MFGR#1','MFGR#3')
GROUP BY        d_month, d_year, s_nation
ORDER BY        d_month, d_year, s_nation
/

