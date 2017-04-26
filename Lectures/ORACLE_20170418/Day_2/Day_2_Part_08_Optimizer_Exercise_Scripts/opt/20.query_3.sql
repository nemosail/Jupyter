@alter.session.sql

SELECT  /*+ monitor */
        SUM(lo_quantity) lo_quantity,
        SUM(lo_revenue) lo_revenue,
        SUM(lo_supplycost) lo_supplycost
        FROM lineorder
                JOIN supplier ON lo_suppkey = s_suppkey
        WHERE   s_nation in ('UNITED KINGDOM')
/

