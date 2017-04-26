@alter.session.sql

select table_name, extension, extension_name
from   user_stat_extensions;

select dbms_stats.create_extended_stats(user, 'SUPPLIER', '(S_REGION,S_NATION,S_CITY)') col_group from dual;

select table_name, extension, extension_name
from   user_stat_extensions;

exec dbms_stats.gather_table_stats(user, 'SUPPLIER', degree=>4);

