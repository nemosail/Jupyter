rem =======================================================================
rem  Loop through and set all tables to parallel default
rem =======================================================================

select table_name, degree from user_tables order by 1;

set serveroutput on

declare
  cursor cur1 is
    select table_name 
    from   user_tables
    order by 1;
  v_sql varchar2(1000);
begin
  for c1 in cur1 loop
    dbms_output.put_line('====================');
    dbms_output.put_line('Table: ' || c1.table_name);
    v_sql := 'alter table ' || c1.table_name || ' parallel';
    dbms_output.put_line(v_sql);
    execute immediate v_sql;
  end loop;
end;
/

select table_name, degree from user_tables order by 1;

