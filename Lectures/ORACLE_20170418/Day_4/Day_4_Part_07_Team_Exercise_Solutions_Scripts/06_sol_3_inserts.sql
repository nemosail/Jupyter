set timing on

alter session enable parallel dml;

rem elter session force parallel query parallel 20;
rem alter session force parallel dml parallel 20;
rem alter session set parallel_force_local = true;

select systimestamp from dual;

truncate table deduplicate_buy;
truncate table deduplicate_sell;

insert /*+ append monitor */ all
when (buy_code is not null
      and sell_code is not null
          and sell_match_rowno = 1
          and sell_dup_rowno = 1
          and buy_match_rowno = 1
          and buy_dup_rowno = 1) then
-- there is a buy record and a sell record that are not duplicates
-- put them into the matched table
  into matched        values (sell_code,
                              sell_source_id,
                              sell_source_account,
                              sell_program_id,
                              sell_transaction_date,
                              sell_transaction_number,
                              sell_value,
                              sell_function,
                              buy_indicator,
                              sell_indicator,
                              buy_comments,
                              sell_comments)
when (sell_code is null 
      and buy_match_rowno = 1 
      and buy_dup_rowno=1) then
-- there is no sell record and at least one buy record (take the 1st one)
-- put the record in the postmatch table to be processed at a later time
  into postmatch_buy  values (buy_code,
                              buy_source_id,
                              buy_source_account,
                              buy_program_id,
                              buy_transaction_date,
                              buy_transaction_number,
                              buy_value,
                              buy_function,
                              buy_indicator,
                              buy_comments)
when (buy_match_rowno > 1 
      or buy_dup_rowno > 1) then
-- there is no sell record and the buy record is already in MATCHED
-- put the duplicate record in the duplicate buy table
  into duplicate_buy  values (buy_code,
                              buy_source_id,
                              buy_source_account,
                              buy_program_id,
                              buy_transaction_date,
                              buy_transaction_number,
                              buy_value,
                              buy_function,
                              buy_indicator,
                              buy_comments)
when (buy_code is null 
      and sell_match_rowno = 1 
      and sell_dup_rowno = 1) then
-- there is no buy record and at least one sell record (take the 1st one)
-- put the record in the postmatch table to be processed at a later time
  into postmatch_sell values (sell_code,
                              sell_source_id,
                              sell_source_account,
                              sell_program_id,
                              sell_transaction_date,
                              sell_transaction_number,
                              sell_value,
                              sell_function,
                              sell_indicator,
                              sell_comments)
when (sell_match_rowno > 1 
      or sell_dup_rowno > 1) then
-- there is no buy record and the sell record is already in MATCHED
-- put the duplicate record in the duplicate sell table
  into duplicate_sell values (sell_code,
                              sell_source_id,
                              sell_source_account,
                              sell_program_id,
                              sell_transaction_date,
                              sell_transaction_number,
                              sell_value,
                              sell_function,
                              sell_indicator,
                              sell_comments)
with 
/*
   Start with the "leftover" unmatched records from the prematch table and  
   combine them with the new de-duped records from the external table and we   
   left outer join that to the MATCHED table to determine if that PK is present. 
   If present, use the IS_IN_MATCHED column alias to track it (NULL if not in   
   MATCHED table). The nvl2 function will evaluate to 1 if no row exists in 
   MATCHED, else it will be 2 representing that PK already exists in MATCHED.
   We do this for both buy and sell records.
*/
pre_match_buy as
( 
  select code,
         source_id,
         source_account,
         program_id,
         transaction_date,
         transaction_number,
         value,
         function,
         indicator,
         comments,
         match_rowno,
         dup_rowno
  from (select a.*,
               nvl2(is_in_matched,2,1) match_rowno
        from   (select b.*, m.code is_in_matched
                from (select a.*,
                             row_number() over (partition by a.code,
                                                             a.source_id,
                                                             a.source_account,
                                                             a.program_id,
                                                             a.transaction_date,
                                                             a.transaction_number,
                                                             a.value,
                                                             a.function
                                                order by a.transaction_date) dup_rowno
                      from (select * from v_ext_buy 
                            union all
                            select * from prematch_buy) a) b 
                     left join matched m
                     on ( m.code               = b.code
                     and  m.source_id          = b.source_id
                     and  m.source_account     = b.source_account
                     and  m.program_id         = b.program_id
                     and  m.transaction_date   = b.transaction_date
                     and  m.transaction_number = b.transaction_number
                     and  m.value              = b.value
                     and  m.function           = b.function )
               ) a
       )
),
pre_match_sell as
(
  select code,
         source_id,
         source_account,
         program_id,
         transaction_date,
         transaction_number,
         value,
         function,
         indicator,
         comments,
         match_rowno,
         dup_rowno
  from (select a.*,
               nvl2(is_in_matched,2,1) match_rowno
        from   (select b.*, m.code is_in_matched
                from (select a.*,
                             row_number() over (partition by a.code,
                                                             a.source_id,
                                                             a.source_account,
                                                             a.program_id,
                                                             a.transaction_date,
                                                             a.transaction_number,
                                                             a.value,
                                                             a.function
                                                order by a.transaction_date) dup_rowno
                      from (select  * from v_ext_sell
                            union all 
                            select * from prematch_sell) a) b 
                     left join matched m
                     on ( m.code               = b.code
                     and  m.source_id          = b.source_id
                     and  m.source_account     = b.source_account
                     and  m.program_id         = b.program_id
                     and  m.transaction_date   = b.transaction_date
                     and  m.transaction_number = b.transaction_number
                     and  m.value              = b.value
                     and  m.function           = b.function )
             ) a
       )
)
select buy.code                buy_code,
       buy.source_id           buy_source_id,
       buy.source_account      buy_source_account,
       buy.program_id          buy_program_id,
       buy.transaction_date    buy_transaction_date,
       buy.transaction_number  buy_transaction_number,
       buy.value               buy_value,
       buy.function            buy_function,
       buy.indicator           buy_indicator,
       buy.comments            buy_comments,
       sell.code               sell_code,
       sell.source_id          sell_source_id,
       sell.source_account     sell_source_account,
       sell.program_id         sell_program_id,
       sell.transaction_date   sell_transaction_date,
       sell.transaction_number sell_transaction_number,
       sell.value              sell_value,
       sell.function           sell_function,
       sell.indicator          sell_indicator,
       sell.comments           sell_comments,
       sell.match_rowno        sell_match_rowno,
       sell.dup_rowno          sell_dup_rowno,
       buy.match_rowno         buy_match_rowno,
       buy.dup_rowno           buy_dup_rowno
from   pre_match_buy buy 
       full outer join pre_match_sell sell
on     buy.code               = sell.code
and    buy.source_id          = sell.source_id
and    buy.source_account     = sell.source_account
and    buy.program_id         = sell.program_id
and    buy.transaction_date   = sell.transaction_date
and    buy.transaction_number = sell.transaction_number
and    buy.value              = sell.value
and    buy.function           = sell.function
;

commit;
--set timing off
--
-- "move" the unmatched buys/sells to the prematch table to be picked up for next time
--

drop table prematch_buy;
drop table prematch_sell;
rename postmatch_buy  to prematch_buy;
rename postmatch_sell to prematch_sell;
create table postmatch_buy parallel nologging as select * from prematch_buy  where 1=0;
create table postmatch_sell parallel nologging as select * from prematch_sell where 1=0;

--@count

select systimestamp from dual;
