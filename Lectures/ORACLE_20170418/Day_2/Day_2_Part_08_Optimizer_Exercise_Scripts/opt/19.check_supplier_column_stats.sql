@alter.session.sql

select table_name,
       column_name,
       num_distinct,
       histogram
from   user_tab_col_statistics
where  table_name = 'SUPPLIER'
order by 2;

select count(*)
from   supplier;

