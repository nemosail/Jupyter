@alter.session.sql

select table_name,
       num_rows,
       blocks,
       last_analyzed
from   user_tab_statistics
where  partition_name is null
order by 1
/

