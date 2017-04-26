exec dbms_stats.export_table_stats(USER, 'PART' ,stattab => 'STATTAB', cascade => TRUE)
