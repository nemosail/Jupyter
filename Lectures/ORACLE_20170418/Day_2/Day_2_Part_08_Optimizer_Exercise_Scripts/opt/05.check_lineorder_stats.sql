@alter.session.sql

select table_name,
       column_name,
       histogram
from   user_tab_col_statistics
where  table_name = 'LINEORDER'
order by 2
/

