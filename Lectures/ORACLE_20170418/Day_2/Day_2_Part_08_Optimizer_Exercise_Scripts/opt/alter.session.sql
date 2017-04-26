set term off
set timing on
set pages 50
set lines 180
set echo on

col d_month format a12
col d_year format  9999
col s_nation format a20
col lo_quantity format 999999999999.99
col lo_revenue format 99999999999999.99
col lo_supplycost format 999999999999.99
col table_name format a30
col column_name format a30
col extension format a40
col extension_name format a30
col col_group format a30
col Name format a30
col type format a30

REM Placeholder for any alter session commands that attendees will use
ALTER SYSTEM FLUSH BUFFER_CACHE;
alter system flush shared_pool;
set term on

