alter session enable parallel dml;

/*
  Prematch Buy Process
*/

select systimestamp from dual;

/*
  Step 1
  Find the records in the external table which match records already in matched table
  Use 'exists' to find the records
  Put rows in duplicate_buy_prematch as a temporary holding place
*/

insert /*+ append */ 
  into duplicate_buy_matched  (code,
                               source_id,
                               source_account,
                               program_id,
                               transaction_date,
                               transaction_number,
                               value,
                               function,
                               indicator,
                               comments)
  select b.code,
         b.source_id,
         b.source_account,
         b.program_id,
         b.transaction_date,
         b.transaction_number,
         b.value,
         b.function,
         b.indicator,
         b.comments
  from   v_ext_buy b
  where  exists (select 'x'
                 from   matched m
                 where  m.code               = b.code
                 and    m.source_id          = b.source_id
                 and    m.source_account     = b.source_account
                 and    m.program_id         = b.program_id
                 and    m.transaction_date   = b.transaction_date
                 and    m.transaction_number = b.transaction_number
                 and    m.value              = b.value
                 and    m.function           = b.function);

commit;

/*
  Step 2
  Find duplicate records in the external table and the records not matched in the previous run
  Use window function to find duplicate rows
  Rows with rowno>1 are duplicates
  Put rows in duplicate_buy_prematch as a temporary holding place
*/

insert /*+ append */ 
  into duplicate_buy_prematch (code,
                               source_id,
                               source_account,
                               program_id,
                               transaction_date,
                               transaction_number,
                               value,
                               function,
                               indicator,
                               comments)
  select b.code,
         b.source_id,
         b.source_account,
         b.program_id,
         b.transaction_date,
         b.transaction_number,
         b.value,
         b.function,
         b.indicator,
         b.comments
  from (select b.*,
               row_number() over (partition by code,
                                               source_id,
                                               source_account,
                                               program_id,
                                               transaction_date,
                                               transaction_number,
                                               value,
                                               function
                                  order by transaction_date) rowno    
        from (select * from v_ext_buy
              union all
              select * from prematch_buy) b) b
  where rowno > 1;
  
commit;

/*
  Step 3
  Load rows into the prematch table minus the rows in duplicate_buy_prematch from previous two steps
  Use minus to exlude rows
*/

insert /*+ append */
    into prematch_buy (code,
                       source_id,
                       source_account,
                       program_id,
                       transaction_date,
                       transaction_number,
                       value,
                       function,
                       indicator,
                       comments)
  select b.code,
         b.source_id,
         b.source_account,
         b.program_id,
         b.transaction_date,
         b.transaction_number,
         b.value,
         b.function,
         b.indicator,
         b.comments
  from   v_ext_buy b
  union
  select p.code,
         p.source_id,
         p.source_account,
         p.program_id,
         p.transaction_date,
         p.transaction_number,
         p.value,
         p.function,
         p.indicator,
         p.comments
  from   postmatch_buy p
  minus
  select d.code,
         d.source_id,
         d.source_account,
         d.program_id,
         d.transaction_date,
         d.transaction_number,
         d.value,
         d.function,
         d.indicator,
         d.comments
  from   duplicate_buy_matched d;

commit;

/*
  Step 4
  Copy rows from the temporary holding place in duplicate_buy_prematch to duplicate_buy
*/

insert /*+ append */
  into duplicate_buy
  select *
  from   duplicate_buy_prematch;

commit;

insert /*+ append */
  into duplicate_buy
  select *
  from   duplicate_buy_matched;

commit;

/*
  Step 5
  Trucate duplicate_buy_prematch so that it is ready for the next run
*/

truncate table duplicate_buy_prematch;
truncate table duplicate_buy_matched;

/*
  Prematch Sell Process
*/

select systimestamp from dual;

/*
  Step 6
  Find the records in the external table which match records already in matched table
  Use 'exists' to find the records
  Put rows in duplicate_sell_prematch as a temporary holding place
*/

insert /*+ append */ 
  into duplicate_sell_matched  (code,
                                source_id,
                                source_account,
                                program_id,
                                transaction_date,
                                transaction_number,
                                value,
                                function,
                                indicator,
                                comments)
  select s.code,
         s.source_id,
         s.source_account,
         s.program_id,
         s.transaction_date,
         s.transaction_number,
         s.value,
         s.function,
         s.indicator,
         s.comments
  from   v_ext_sell s
  where  exists (select 'x'
                 from   matched m
                 where  m.code = s.code
                 and    m.source_id          = s.source_id
                 and    m.source_account     = s.source_account
                 and    m.program_id         = s.program_id
                 and    m.transaction_date   = s.transaction_date
                 and    m.transaction_number = s.transaction_number
                 and    m.value              = s.value
                 and    m.function           = s.function);

commit;

/*
  Step 7
  Find duplicate records in the external table and the records not matched in the previous run
  Use window function to find duplicate rows
  Rows with rowno>1 are duplicates
  Put rows in duplicate_sell_prematch as a temporary holding place
*/

insert /*+ append */ 
  into duplicate_sell_prematch (code,
                                source_id,
                                source_account,
                                program_id,
                                transaction_date,
                                transaction_number,
                                value,
                                function,
                                indicator,
                                comments)
  select s.code,
         s.source_id,
         s.source_account,
         s.program_id,
         s.transaction_date,
         s.transaction_number,
         s.value,
         s.function,
         s.indicator,
         s.comments
  from (select s.*,
               row_number() over (partition by code,
                                               source_id,
                                               source_account,
                                               program_id,
                                               transaction_date,
                                               transaction_number,
                                               value,
                                               function
                                  order by transaction_date) rowno    
        from (select * from v_ext_sell
              union all
              select * from prematch_sell) s) s
  where rowno > 1;
  
commit;

/*
  Step 8
  Load rows into the prematch table minus the rows in duplicate_sell_prematch from previous two steps
  Use minus to exlude rows
*/

insert /*+ append */
    into prematch_sell (code,
                        source_id,
                        source_account,
                        program_id,
                        transaction_date,
                        transaction_number,
                        value,
                        function,
                        indicator,
                        comments)
  select s.code,
         s.source_id,
         s.source_account,
         s.program_id,
         s.transaction_date,
         s.transaction_number,
         s.value,
         s.function,
         s.indicator,
         s.comments
  from   v_ext_sell s
  union
  select p.code,
         p.source_id,
         p.source_account,
         p.program_id,
         p.transaction_date,
         p.transaction_number,
         p.value,
         p.function,
         p.indicator,
         p.comments
  from   postmatch_sell p
  minus
  select d.code,
         d.source_id,
         d.source_account,
         d.program_id,
         d.transaction_date,
         d.transaction_number,
         d.value,
         d.function,
         d.indicator,
         d.comments
  from   duplicate_sell_matched d;

commit;

/*
  Step 9
  Copy rows from the temporary holding place in duplicate_sell_prematch to duplicate_sell
*/

insert /*+ append */
  into duplicate_sell
  select *
  from   duplicate_sell_prematch;

commit;

insert /*+ append */
  into duplicate_sell
  select *
  from   duplicate_sell_matched;

commit;

/*
  Step 10
  Trucate duplicate_sell_prematch so that it is ready for the next run
*/

truncate table duplicate_sell_prematch;
truncate table duplicate_sell_matched;

select systimestamp from dual;

/*
  Match Process
*/

/*
  Step 11
  Insert matching rows in prematch_buy and prematch_sell into matched table
  Use join to find matching rows
*/

insert /*+ append */
  into matched
select buy.code buy_code,
       buy.source_id buy_source_id,
       buy.source_account buy_source_account,
       buy.program_id buy_program_id,
       buy.transaction_date buy_transaction_date,
       buy.transaction_number buy_transaction_number,
       buy.value buy_value,
       buy.function buy_function,
       buy.indicator buy_indicator,
       sell.indicator sell_indicator,
       buy.comments buy_comments,
       sell.comments sell_comments
from   prematch_buy buy
join   prematch_sell sell
on     buy.code               = sell.code
and    buy.source_id          = sell.source_id
and    buy.source_account     = sell.source_account
and    buy.program_id         = sell.program_id
and    buy.transaction_date   = sell.transaction_date
and    buy.transaction_number = sell.transaction_number
and    buy.value              = sell.value
and    buy.function           = sell.function;

commit;

/*
  Step 12
  Copy rows from prematch_buy that did not match into the postmatch_buy table
  Use 'not exists' to remove rows not in mached
*/

truncate table postmatch_buy;

insert /*+ append */
  into   postmatch_buy
  select *
  from   prematch_buy b
  where  not exists (select 'x'
                     from   matched m
                     where  m.code               = b.code
                     and    m.source_id          = b.source_id
                     and    m.source_account     = b.source_account
                     and    m.program_id         = b.program_id
                     and    m.transaction_date   = b.transaction_date
                     and    m.transaction_number = b.transaction_number
                     and    m.value              = b.value
                     and    m.function           = b.function);

commit;

/*
  Step 13
  Copy rows from prematch_sell that did not match into the postmatch_sell table
  Use 'not exists' to remove rows not in mached
*/

truncate table postmatch_sell;

insert /*+ append */
  into   postmatch_sell
  select *
  from   prematch_sell s
  where  not exists (select 'x'
                     from   matched m
                     where  m.code               = s.code
                     and    m.source_id          = s.source_id
                     and    m.source_account     = s.source_account
                     and    m.program_id         = s.program_id
                     and    m.transaction_date   = s.transaction_date
                     and    m.transaction_number = s.transaction_number
                     and    m.value              = s.value
                     and    m.function           = s.function);

commit;

select systimestamp from dual;

/*
  Postmatch Process
*/

/*
  Step 14
  Drop prematch tables
  Rename postmatch tables to prematch tables, thereby getting unmatched rows ready for processing in the next run
  Create empty postmach tables for next run
*/

truncate table prematch_buy;
truncate table prematch_sell;

select systimestamp from dual;
