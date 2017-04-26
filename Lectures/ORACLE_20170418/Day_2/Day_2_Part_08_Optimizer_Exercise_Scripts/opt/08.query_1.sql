@alter.session.sql

SELECT  /*+ monitor */
        SUM(lo_quantity) lo_quantity,
        SUM(lo_revenue) lo_revenue,
        SUM(lo_supplycost) lo_supplycost
        FROM lineorder
        WHERE   lo_promotion_id='192000'
        AND     lo_orderpriority = '1-URGENT'
        AND     lo_shipmode = 'MAIL'
/

