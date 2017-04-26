rem ============================================================================
rem  Create intermediate tables to hold data
rem  postmatch tables hold data that did not match to be used in next bath cycle
rem  duplicate tables are used to hold records in the prematch process
rem ============================================================================

create table postmatch_buy parallel nologging as select * from prematch_buy where rownum<1;
create table postmatch_sell parallel nologging as select * from prematch_sell where rownum<1;

create table duplicate_buy_prematch parallel nologging as select * from duplicate_buy where 1=0;
create table duplicate_sell_prematch parallel nologging as select * from duplicate_sell where 1=0;
