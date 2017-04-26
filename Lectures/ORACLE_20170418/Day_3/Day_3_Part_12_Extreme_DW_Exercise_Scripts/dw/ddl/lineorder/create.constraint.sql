alter table
 lineorder
add constraint
 lo_customer_fk
foreign key
(
 lo_custkey
)
references
 customer
(
 c_custkey
)
rely disable novalidate
;
alter table
 lineorder
add constraint
 lo_date_dim_fk
foreign key
(
 lo_orderdate
)
references
 date_dim
(
 d_datekey
)
rely disable novalidate
;
alter table
 lineorder
add constraint
 lo_part_fk
foreign key
(
 lo_partkey
)
references
 part
(
 p_partkey
)
rely disable novalidate
;
alter table
 lineorder
add constraint
 lo_supplier_fk
foreign key
(
 lo_suppkey
)
references
 supplier
(
 s_suppkey
)
rely disable novalidate
;
