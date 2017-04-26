create or replace package body matching 
is
  -- This is the body of the matching package
  --
  -- use a common cursor type for all dynamic SQL statements
  type rec_cur is ref cursor;
  --
  --
  -- A few contants used to create table names
  -- Most tables are duplicated for the two sides and
  -- the real table name is made from concatenating
  -- on of these constants with '1' or '2' for the side
  n_duplicate  constant varchar2(20) := 'DUPLICATE_';
  n_prematch   constant varchar2(20) := 'PREMATCH_';
  --
  --
  procedure initialize is
  -- initialize by truncating tables
  --
  begin
    -- For the first run, truncate all tables
    execute immediate 'truncate table matched';
    execute immediate 'truncate table prematch_buy';
    execute immediate 'truncate table duplicate_buy';
    execute immediate 'truncate table prematch_sell';
    execute immediate 'truncate table duplicate_sell';
  end;
  --
  --
  --
  --
  --
  --
  function is_matched(rec type_table%rowtype)
  -- See if this row is already matched
  --
  -- We do this by counting the number of rows
  -- based on the primary key and the verification columns
  return boolean 
  is
    l_cnt number;
  begin
    select count(*)
    into l_cnt
    from matched m
    -- primary key columns
    where  m.CODE = rec.CODE
      and  m.SOURCE_ID = rec.SOURCE_ID
      and  m.SOURCE_ACCOUNT = rec.SOURCE_ACCOUNT
      and  m.PROGRAM_ID = rec.PROGRAM_ID
      and  m.TRANSACTION_DATE = rec.TRANSACTION_DATE
      and  m.TRANSACTION_NUMBER = rec.TRANSACTION_NUMBER
      and  m.VALUE = rec.VALUE
      and  m.FUNCTION = rec.FUNCTION;
    -- exactly one row means a match.  As the primary key
    -- is part of the where predicate, count cannot be 
    -- larger than 1.
    if l_cnt = 1
    then
      return true;
    else
      return false;
    end if;
  end is_matched;
  --
  --
  --
  --
  --
  procedure prematch_buy(p_src varchar2)
  -- Copy rows from p_src (an external table) to p_dst (a prematch table)
  -- If there is a primary key violation during the insert, the row
  -- is in stead inserted into the p_dup table.
  --
  is
    cur rec_cur;
    rec type_table%rowtype;
  begin
    -- open a cursor to select from the external table
    open cur for select * from v_ext_buy;
    --
    -- we loop over all records in the external table
    loop
      fetch cur into 
	  rec.CODE 
	, rec.SOURCE_ID 
	, rec.SOURCE_ACCOUNT 
	, rec.PROGRAM_ID 
	, rec.TRANSACTION_DATE 
	, rec.TRANSACTION_NUMBER 
	, rec.VALUE 
	, rec.FUNCTION 
	, rec.INDICATOR 
	, rec.COMMENTS ;
      exit when cur%notfound;
      if is_matched(rec)
      then
	-- If the row is already in the MATCHED table
	-- (from a previous run), insert into to p_dup
        -- insert_row(p_dup, rec);
        insert into duplicate_buy
      ( CODE 
      , SOURCE_ID 
      , SOURCE_ACCOUNT 
      , PROGRAM_ID 
      , TRANSACTION_DATE 
      , TRANSACTION_NUMBER 
      , VALUE 
      , FUNCTION 
      , INDICATOR 
      , COMMENTS 
      ) values (
	rec.CODE 
      , rec.SOURCE_ID 
      , rec.SOURCE_ACCOUNT 
      , rec.PROGRAM_ID 
      , rec.TRANSACTION_DATE 
      , rec.TRANSACTION_NUMBER 
      , rec.VALUE 
      , rec.FUNCTION 
      , rec.INDICATOR 
      , rec.COMMENTS);
      else
        -- Otherwise, insert it into prematch
        begin
	  --insert_row(p_dst, rec)
            insert into prematch_buy
          ( CODE 
          , SOURCE_ID 
          , SOURCE_ACCOUNT 
          , PROGRAM_ID 
          , TRANSACTION_DATE 
          , TRANSACTION_NUMBER 
          , VALUE 
          , FUNCTION 
          , INDICATOR 
          , COMMENTS 
          ) values (
            rec.CODE 
          , rec.SOURCE_ID 
          , rec.SOURCE_ACCOUNT 
          , rec.PROGRAM_ID 
          , rec.TRANSACTION_DATE 
          , rec.TRANSACTION_NUMBER 
          , rec.VALUE 
          , rec.FUNCTION 
          , rec.INDICATOR 
          , rec.COMMENTS);
	exception when dup_val_on_index then
	  -- In case of a duplicate row insert it as an error row
	  -- into the duplicate table
                insert into duplicate_buy
              ( CODE 
              , SOURCE_ID 
              , SOURCE_ACCOUNT 
              , PROGRAM_ID 
              , TRANSACTION_DATE 
              , TRANSACTION_NUMBER 
              , VALUE 
              , FUNCTION 
              , INDICATOR 
              , COMMENTS 
              ) values (
                rec.CODE 
              , rec.SOURCE_ID 
              , rec.SOURCE_ACCOUNT 
              , rec.PROGRAM_ID 
              , rec.TRANSACTION_DATE 
              , rec.TRANSACTION_NUMBER 
              , rec.VALUE 
              , rec.FUNCTION 
              , rec.INDICATOR 
              , rec.COMMENTS);
      end;
      end if;
      --
      commit write wait;
    end loop;
    close cur;
  end prematch_buy;
  --
  procedure prematch_sell(p_src varchar2)
  -- Copy rows from p_src (an external table) to p_dst (a prematch table)
  -- If there is a primary key violation during the insert, the row
  -- is in stead inserted into the p_dup table.
  --
  is
    cur rec_cur;
    rec type_table%rowtype;
  begin
    -- open a cursor to select from the external table
    open cur for select * from v_ext_sell;
    --
    -- we loop over all records in the external table
    loop
      fetch cur into 
	  rec.CODE 
	, rec.SOURCE_ID 
	, rec.SOURCE_ACCOUNT 
	, rec.PROGRAM_ID 
	, rec.TRANSACTION_DATE 
	, rec.TRANSACTION_NUMBER 
	, rec.VALUE 
	, rec.FUNCTION 
	, rec.INDICATOR 
	, rec.COMMENTS ;
      exit when cur%notfound;
      if is_matched(rec)
      then
	-- If the row is already in the MATCHED table
	-- (from a previous run), insert into to p_dup
        -- insert_row(p_dup, rec);
        insert into duplicate_sell
      ( CODE 
      , SOURCE_ID 
      , SOURCE_ACCOUNT 
      , PROGRAM_ID 
      , TRANSACTION_DATE 
      , TRANSACTION_NUMBER 
      , VALUE 
      , FUNCTION 
      , INDICATOR 
      , COMMENTS 
      ) values (
	rec.CODE 
      , rec.SOURCE_ID 
      , rec.SOURCE_ACCOUNT 
      , rec.PROGRAM_ID 
      , rec.TRANSACTION_DATE 
      , rec.TRANSACTION_NUMBER 
      , rec.VALUE 
      , rec.FUNCTION 
      , rec.INDICATOR 
      , rec.COMMENTS);
      else
        -- Otherwise, insert it into prematch
        begin
	  --insert_row(p_dst, rec)
            insert into prematch_sell
          ( CODE 
          , SOURCE_ID 
          , SOURCE_ACCOUNT 
          , PROGRAM_ID 
          , TRANSACTION_DATE 
          , TRANSACTION_NUMBER 
          , VALUE 
          , FUNCTION 
          , INDICATOR 
          , COMMENTS 
          ) values (
            rec.CODE 
          , rec.SOURCE_ID 
          , rec.SOURCE_ACCOUNT 
          , rec.PROGRAM_ID 
          , rec.TRANSACTION_DATE 
          , rec.TRANSACTION_NUMBER 
          , rec.VALUE 
          , rec.FUNCTION 
          , rec.INDICATOR 
          , rec.COMMENTS);
	exception when dup_val_on_index then
	  -- In case of a duplicate row insert it as an error row
	  -- into the duplicate table
                insert into duplicate_sell
              ( CODE 
              , SOURCE_ID 
              , SOURCE_ACCOUNT 
              , PROGRAM_ID 
              , TRANSACTION_DATE 
              , TRANSACTION_NUMBER 
              , VALUE 
              , FUNCTION 
              , INDICATOR 
              , COMMENTS 
              ) values (
                rec.CODE 
              , rec.SOURCE_ID 
              , rec.SOURCE_ACCOUNT 
              , rec.PROGRAM_ID 
              , rec.TRANSACTION_DATE 
              , rec.TRANSACTION_NUMBER 
              , rec.VALUE 
              , rec.FUNCTION 
              , rec.INDICATOR 
              , rec.COMMENTS);
      end;
      end if;
      --
      commit write wait;
    end loop;
    close cur;
  end prematch_sell;
  --
  --
  procedure match
  -- Match data from the two sides by moving matched rows from the prematch
  -- tables into the matched table.  
  -- 
  -- Non matched rows are left in the prematch tables
  -- Duplicate matches are moved to the duplicate table
  is
    -- cursor to read from side 1
    cur1 rec_cur;
    -- records of the two sides
    rec2 type_table%rowtype;
    -- rowid from side 2
    rid2 rowid;
  begin
    -- 
    -- we loop over all records in the prematch table from side 1
    for rec1 in (select x1.*, x1.rowid from prematch_buy x1)
    loop
      --
      begin
	-- find the matching row in the other table
	-- note that an exception below handles row not found
	select x2.*, x2.rowid
	into 
	    rec2.CODE 
	  , rec2.SOURCE_ID 
	  , rec2.SOURCE_ACCOUNT 
	  , rec2.PROGRAM_ID 
	  , rec2.TRANSACTION_DATE 
	  , rec2.TRANSACTION_NUMBER 
	  , rec2.VALUE 
	  , rec2.FUNCTION 
	  , rec2.INDICATOR 
	  , rec2.COMMENTS 
	  , rid2
	from prematch_sell x2
	where  x2.CODE = rec1.CODE
	  and  x2.SOURCE_ID = rec1.SOURCE_ID
	  and  x2.SOURCE_ACCOUNT = rec1.SOURCE_ACCOUNT
	  and  x2.PROGRAM_ID = rec1.PROGRAM_ID
	  and  x2.TRANSACTION_DATE = rec1.TRANSACTION_DATE
	  and  x2.TRANSACTION_NUMBER = rec1.TRANSACTION_NUMBER
	  and  x2.VALUE = rec1.VALUE
	  and  x2.FUNCTION = rec1.FUNCTION;
	-- If we come here we have a matching record from the two sides
	-- From side 1, the record comes from the cursor, from side 2,
	-- the record comes from the query above
	-- 
	-- Now insert the record into the matched tabled.
	-- This table (as the only one) has somewhat different columns
	-- as it holds the extra columns (indicator and comments) from
	-- both the sources
	insert into matched 
	  ( CODE 
	  , SOURCE_ID 
	  , SOURCE_ACCOUNT 
	  , PROGRAM_ID
	  , TRANSACTION_DATE
	  , TRANSACTION_NUMBER
	  , VALUE
	  , FUNCTION
	  , INDICATOR_1
	  , INDICATOR_2
	  , COMMENTS_1 
	  , COMMENTS_2
	  )
	values 
	  ( rec1.CODE 
	  , rec1.SOURCE_ID 
	  , rec1.SOURCE_ACCOUNT 
	  , rec1.PROGRAM_ID 
	  , rec1.TRANSACTION_DATE 
	  , rec1.TRANSACTION_NUMBER 
	  , rec1.VALUE 
	  , rec1.FUNCTION 
	  , rec1.INDICATOR 
	  , rec2.INDICATOR
	  , rec1.COMMENTS 
	  , rec2.COMMENTS
	  );
	-- and delete both source rows
	delete from prematch_buy where rowid = rec1.rowid;
	delete from prematch_sell where rowid = rid2;
	commit write wait;
      exception when no_data_found then
        -- This no_data_found exception can potentially 
	-- happen when we lookup in side 2 with the data
	-- from side 1.  
	--
	-- By simply ignoring the exception, we effectively
	-- keep the rows in both sides.
        null;
      end ;
    end loop;
  end match;
  --
  --
  --
end matching;
/
show errors
