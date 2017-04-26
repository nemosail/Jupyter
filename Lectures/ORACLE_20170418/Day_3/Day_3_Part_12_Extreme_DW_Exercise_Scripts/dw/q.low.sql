@alter.session.sql

SELECT  /* low */
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
        WHERE   d_year = 1997
	AND     d_month = 'January'
	AND 	d_dayofweek = 'Sunday'
        AND     p_mfgr = 'MFGR#4'
	AND 	p_category = 'MFGR#41'
	AND     p_color = 'yellow'
	AND     s_region = 'AMERICA'
GROUP BY        d_sellingseason, p_category, s_region
ORDER BY        d_sellingseason, p_category, s_region
/
