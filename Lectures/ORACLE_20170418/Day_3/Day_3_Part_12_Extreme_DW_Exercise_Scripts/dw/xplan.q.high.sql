@alter.session.sql

EXPLAIN PLAN FOR 
SELECT  
	d_month, d_year, s_nation, 
	SUM(lo_quantity) lo_quantity, 
	SUM(lo_revenue) lo_revenue, 
	SUM(lo_supplycost) lo_supplycost
	FROM lineorder
		JOIN customer 	ON lo_custkey = c_custkey
		JOIN date_dim 	ON lo_orderdate = d_datekey
		JOIN part 	ON lo_partkey = p_partkey
		JOIN supplier	ON lo_suppkey = s_suppkey
 	WHERE   d_year = 1997
	AND 	s_region = 'ASIA'
        AND     p_mfgr in ('MFGR#1','MFGR#2','MFGR#3','MFGR#4')
GROUP BY 	d_month, d_year, s_nation
ORDER BY 	d_month, d_year, s_nation
/

@xplan
