rem =======================================================================
rem  Change view definitions to process pairs of files
rem =======================================================================

create or replace view v_ext_buy  as select * from t1_2001&1._et;

create or replace view v_ext_sell as select * from t2_2001&1._et;

