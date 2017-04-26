exec dbms_stats.import_table_stats(USER, 'PART' ,stattab => 'STATTAB', cascade => TRUE, no_invalidate => FALSE)
