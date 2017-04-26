select 'MATCHED' tab, count(*) row_count from MATCHED
union all
select 'PREMATCH_BUY'   tab, count(*) row_count from PREMATCH_BUY
union all
select 'PREMATCH_SELL'  tab, count(*) row_count from PREMATCH_SELL
union all
select 'DUPLICATE_BUY'  tab, count(*) row_count from DUPLICATE_BUY
union all 
select 'DUPLICATE_SELL' tab, count(*) row_count from DUPLICATE_SELL
union all
select 'POSTMATCH_BUY'   tab, count(*) row_count from POSTMATCH_BUY
union all
select 'POSTMATCH_SELL'  tab, count(*) row_count from POSTMATCH_SELL
;
