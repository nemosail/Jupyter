@alter.session.sql

exec dbms_stats.gather_table_stats(user, 'LINEORDER', degree=>4);

