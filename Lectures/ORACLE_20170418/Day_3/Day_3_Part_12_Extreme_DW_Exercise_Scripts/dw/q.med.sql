@alter.session.sql

SELECT  /* med */
        /*+ monitor */
        d_sellingseason, 
	p_category, 
	s_region, 
	SUM(lo_extendedprice)
        FROM    lineorder
                JOIN    customer        ON lo_custkey = c_custkey
                JOIN    date_dim        ON lo_orderdate = d_datekey
                JOIN    part            ON lo_partkey = p_partkey
                JOIN    supplier        ON lo_suppkey = s_suppkey
        WHERE   d_year in (1993) and d_monthnuminyear in (12, 1)
        AND     p_mfgr = 'MFGR#1' and p_category='MFGR#12'
GROUP BY        d_sellingseason, p_category, s_region
ORDER BY        d_sellingseason, p_category, s_region
/
