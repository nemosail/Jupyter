exec dbms_stats.export_table_stats(USER, 'LINEORDER' ,stattab => 'STATTAB', cascade => TRUE)
