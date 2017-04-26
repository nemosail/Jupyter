exec dbms_stats.export_table_stats(USER, 'DATE_DIM' ,stattab => 'STATTAB', cascade => TRUE)
