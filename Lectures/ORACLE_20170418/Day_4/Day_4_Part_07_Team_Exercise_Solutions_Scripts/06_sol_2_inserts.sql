alter session enable parallel dml;

/*
=================================================
  Prematch Buy Process
=================================================
*/

select systimestamp from dual;

insert /*+ append */ first
  when rowno > 1 then
/*
  When rowno > 1 it is a duplicate, so insert into the duplicate_buy table
*/  
    into duplicate_buy values(code,
                              source_id,
                              source_account,
                              program_id,
                              transaction_date,
                              transaction_number,
                              value,
                              function,
                              indicator,
                              comments)
  when is_in_matched is not null then
/*
  The is_in_matched column is coming from the matched table, 
  so if it has a value, the row is already in matched
  and is inserted into the duplicate_buy table
*/  
    into duplicate_buy values(code,
                              source_id,
                              source_account,
                              program_id,
                              transaction_date,
                              transaction_number,
                              value,
                              function,
                              indicator,
                              comments)
  else
/*
  Rows that are not duplicates are inserted into prematch_buy
*/  
    into prematch_buy values(code,
                             source_id,
                             source_account,
                             program_id,
                             transaction_date,
                             transaction_number,
                             value,
                             function,
                             indicator,
                             comments)
  with buy as
/*
  Find the duplicate rows between the external table and the rows left over from the previous run
  Use a window function to identify duplicate rows
  Rows with rowno > 1 are duplicates
*/
  (  select code,
            source_id,
            source_account,
            program_id,
            transaction_date,
            transaction_number,
            value,
            function,
            indicator,
            comments,
            rowno
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
                select * from postmatch_buy ) b)
  )
/*
  Join rows from inline view with the matched table
  Use a left outer join to get all rows from inline view
  Use is_in_matched to identify rows that are also in the matched table
*/
  select b.code,
         b.source_id,
         b.source_account,
         b.program_id,
         b.transaction_date,
         b.transaction_number,
         b.value,
         b.function,
         b.indicator,
         b.comments,
         b.rowno,
         m.code is_in_matched
  from   buy b
         left outer join matched m
         on ( m.code               = b.code
         and  m.source_id          = b.source_id
         and  m.source_account     = b.source_account
         and  m.program_id         = b.program_id
         and  m.transaction_date   = b.transaction_date
         and  m.transaction_number = b.transaction_number
         and  m.value              = b.value
         and  m.function           = b.function );

commit;

/*
  Trucate the postmatch_buy table so it is ready for the next run
*/

truncate table postmatch_buy;

/*
=================================================
  Prematch Sell Process
=================================================
*/

select systimestamp from dual;

insert /*+ append */ first
  when rowno > 1 then
/*
  When rowno > 1 it is a duplicate, so insert into the duplicate_sell table
*/  
    into duplicate_sell values(code,
                               source_id,
                               source_account,
                               program_id,
                               transaction_date,
                               transaction_number,
                               value,
                               function,
                               indicator,
                               comments)
  when is_in_matched is not null then
/*
  The is_in_matched column is coming from the matched table, 
  so if it has a value, the row is already in matched
  and is inserted into the duplicate_sell table
*/  
    into duplicate_sell values(code,
                               source_id,
                               source_account,
                               program_id,
                               transaction_date,
                               transaction_number,
                               value,
                               function,
                               indicator,
                               comments)
  else
/*
  Rows that are not duplicates are inserted into prematch_sell
*/  
    into prematch_sell values(code,
                              source_id,
                              source_account,
                              program_id,
                              transaction_date,
                              transaction_number,
                              value,
                              function,
                              indicator,
                              comments)
  with sell as
/*
  Find the duplicate rows between the external table and the rows left over from the previous run
  Use a window function to identify buplicate rows
  Rows with rowno > 1 are duplicates
*/
  (  select code,
            source_id,
            source_account,
            program_id,
            transaction_date,
            transaction_number,
            value,
            function,
            indicator,
            comments,
            rowno
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
                select * from postmatch_sell ) s)
  )
/*
  Join rows from inline view with the matched table
  Use a left outer join to get all rows from inline view
  Use is_in_matched to identify rows that are also in the matched table
*/
  select s.code,
         s.source_id,
         s.source_account,
         s.program_id,
         s.transaction_date,
         s.transaction_number,
         s.value,
         s.function,
         s.indicator,
         s.comments,
         s.rowno,
         m.code is_in_matched
  from   sell s
         left outer join matched m
         on ( m.code               = s.code
         and  m.source_id          = s.source_id
         and  m.source_account     = s.source_account
         and  m.program_id         = s.program_id
         and  m.transaction_date   = s.transaction_date
         and  m.transaction_number = s.transaction_number
         and  m.value              = s.value
         and  m.function           = s.function );

commit;

/*
  Trucate the postmatch_sell table so it is ready for the next run
*/

truncate table postmatch_sell;

select systimestamp from dual;

/*
=================================================
  Match Process
=================================================
*/

insert /*+ append  */ first  
  when sell_code is null then
/*
  when there is no value in sell_code, there is a buy record with no matching sell record
  so insert into postmatch_buy to be processed again during the next run
*/  
    into postmatch_buy values(buy_code,
                              buy_source_id,
                              buy_source_account,
                              buy_program_id,
                              buy_transaction_date,
                              buy_transaction_number,
                              buy_value,
                              buy_function,
                              buy_indicator,
                              buy_comments)
  when buy_code is null then
/*
  when there is no value in buy_code, there is a sell record with no matching buy record
  so insert into postmatch_sell to be processed again during the next run
*/  
    into postmatch_sell values(sell_code,
                               sell_source_id,
                               sell_source_account,
                               sell_program_id,
                               sell_transaction_date,
                               sell_transaction_number,
                               sell_value,
                               sell_function,
                               sell_indicator,
                               sell_comments)
  else
/*
  all other rows match and are insert into matched
*/  
    into matched values(buy_code,
                        buy_source_id,
                        buy_source_account,
                        buy_program_id,
                        buy_transaction_date,
                        buy_transaction_number,
                        buy_value,
                        buy_function,
                        buy_indicator,
                        sell_indicator,
                        buy_comments,
                        sell_comments)
/*
  Join the prematch_buy and prematch_sell tables
  Use a full outer join to get rows that match and do not match
*/  
select buy.code buy_code,
       buy.source_id buy_source_id,
       buy.source_account buy_source_account,
       buy.program_id buy_program_id,
       buy.transaction_date buy_transaction_date,
       buy.transaction_number buy_transaction_number,
       buy.value buy_value,
       buy.function buy_function,
       buy.indicator buy_indicator,
       buy.comments buy_comments,
       sell.code sell_code,
       sell.source_id sell_source_id,
       sell.source_account sell_source_account,
       sell.program_id sell_program_id,
       sell.transaction_date sell_transaction_date,
       sell.transaction_number sell_transaction_number,
       sell.value sell_value,
       sell.function sell_function,
       sell.indicator sell_indicator,
       sell.comments sell_comments
from   prematch_buy buy 
       full outer join prematch_sell sell
on     buy.code               = sell.code
and    buy.source_id          = sell.source_id
and    buy.source_account     = sell.source_account
and    buy.program_id         = sell.program_id
and    buy.transaction_date   = sell.transaction_date
and    buy.transaction_number = sell.transaction_number
and    buy.value              = sell.value
and    buy.function           = sell.function;

commit;

select systimestamp from dual;

/*
=================================================
  Postmatch Process
=================================================
*/

/*
  Truncate the prematch tables so they are ready for the next run
*/
truncate table prematch_buy;
truncate table prematch_sell;

select systimestamp from dual;
