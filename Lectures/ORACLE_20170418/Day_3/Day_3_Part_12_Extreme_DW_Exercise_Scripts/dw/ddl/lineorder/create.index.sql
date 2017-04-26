create index
 lo_commitdate_n
on
 lineorder
(
 lo_commitdate
)
local
;
create index
 lo_cust_n
on
 lineorder
(
 lo_custkey
)
local
;
create index
 lo_date_n
on
 lineorder
(
 lo_orderdate
)
local
;
create index
 lo_part_n
on
 lineorder
(
 lo_partkey
)
local
;
create index
 lo_supp_n
on
 lineorder
(
 lo_suppkey
)
local
;
