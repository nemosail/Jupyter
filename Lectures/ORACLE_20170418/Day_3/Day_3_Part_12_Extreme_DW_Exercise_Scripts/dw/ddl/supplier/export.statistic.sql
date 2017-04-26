exec dbms_stats.export_table_stats(USER, 'SUPPLIER' ,stattab => 'STATTAB', cascade => TRUE)
