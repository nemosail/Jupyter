rem =======================================================================
rem  Change pk and unique constraints to rely disable novalidate
rem  to remove indexes
rem =======================================================================

select table_name, 
       constraint_name,
	   constraint_type,
	   rely,
	   status,
	   validated
from   user_constraints
where  constraint_type in ('P','U')
order by 1;

select table_name, index_name from user_indexes;

set serveroutput on

declare
  cursor cur1 is
    select table_name, 
           constraint_name,
	       constraint_type,
    	   rely,
	       status,
    	   validated
    from   user_constraints
    where  constraint_type in ('P','U')
    order by 1;
  v_sql varchar2(1000);
begin
  for c1 in cur1 loop
    dbms_output.put_line('====================');
    dbms_output.put_line('Table: ' || c1.table_name);
    v_sql := 'alter table ' || c1.table_name || ' modify constraint ' || c1.constraint_name || ' rely disable novalidate';
    dbms_output.put_line(v_sql);
    execute immediate v_sql;
    end loop;
end;
/

select table_name, 
       constraint_name,
	   constraint_type,
	   rely,
	   status,
	   validated
from   user_constraints
where  constraint_type in ('P','U')
order by 1;

select table_name, index_name from user_indexes;
