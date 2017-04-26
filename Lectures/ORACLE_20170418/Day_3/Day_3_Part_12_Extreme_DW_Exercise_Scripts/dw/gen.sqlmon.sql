set trimspool on
set arraysize 512
set trim on
set pagesize 0
set linesize 1000
set long 1000000
set longchunksize 1000000
spool sqlmon.html
select /*+ noparallel */ dbms_sqltune.report_sql_monitor (session_id=>userenv('sid'), report_level=>'ALL', type=>'ACTIVE') from dual;
spool off
