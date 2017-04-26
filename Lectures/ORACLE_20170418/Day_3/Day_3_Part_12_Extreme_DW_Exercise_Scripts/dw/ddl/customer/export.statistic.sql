exec dbms_stats.export_table_stats(USER, 'CUSTOMER' ,stattab => 'STATTAB', cascade => TRUE)
