#!/bin/bash

usr=$USER
pwd=$USER

if test $# -gt 2
then
  echo usage: $0 tablesuffix {init}
  exit 1
fi
if test $# -lt 1
then
  echo usage: $0 tablesuffix {init}
  exit 1
fi

table_suffix=$1

# Initialize (TRUNCATE) the tables if init mode specified
if test $2 = init
then
  sqlplus -s -l $usr/$pwd <<END
prompt "Initializing"
exec matching.initialize;
exit
END
fi

# Create views to map the specified external tables to known names
# e.g. if the user specifies 2001A_ET on the command line, then:
# T1_2001A_ET is mapped to v_ext_buy
# T2_2001A_ET is mapped to v_ext_sell
sqlplus -s -l $usr/$pwd <<END
prompt Creating Views
create or replace view v_ext_buy as select * from T1_${table_suffix};
create or replace view v_ext_sell as select * from t2_${table_suffix};
exit
END

# First load all the buy records
sqlplus -s -l $usr/$pwd <<END
prompt Running prematch buy
exec matching.prematch_buy('t1_${table_suffix}');
exit
END

# Next load all the sell records
sqlplus -s -l $usr/$pwd <<END
prompt Running prematch sell
exec matching.prematch_sell('t2_${table_suffix}');
exit
END

# Now match the buy and sell records
sqlplus -s -l $usr/$pwd <<END
prompt Running match
exec matching.match;
exit
END

# Finally report the number of records matched and unmatched
sqlplus -s -l $usr/$pwd <<END
prompt Table Count verification
select count(*) match_count from matched;
select count(*) prematch_1_count from prematch_buy;
select count(*) prematch_2_count from prematch_sell;
exit
END

