@alter.session.sql

exec dbms_stats.gather_table_stats(user, 'SUPPLIER', degree=>4);

