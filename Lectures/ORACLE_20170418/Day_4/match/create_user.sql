host rm -f define_usr_name.sql
host echo define usr_log=$USER > define_usr_name.sql
host echo define usr=${USER} >> define_usr_name.sql
@define_usr_name
host rm -f define_usr_name.sql
set echo on 
drop user &usr cascade
/
create user &usr identified by &usr quota unlimited on users
/
grant create session
, create table
, alter session
, create procedure
, create view
, create synonym
, create sequence
, select_catalog_role
--, plustrace
to &usr
/
create or replace directory data as '/dbfsmnt/staging_area/teams/data'
/
create or replace directory log_dir as '/dbfsmnt/staging_area/teams/log/&usr_log.'
/
grant read on directory data to &usr
/
grant read,write on directory log_dir to &usr
/
exit

