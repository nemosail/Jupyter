0 explain plan for
.
/
select * from table(dbms_xplan.display)
;
select leaf_blocks from user_indexes where table_name = 'LINEORDER' and index_name = upper('&1.')
;
