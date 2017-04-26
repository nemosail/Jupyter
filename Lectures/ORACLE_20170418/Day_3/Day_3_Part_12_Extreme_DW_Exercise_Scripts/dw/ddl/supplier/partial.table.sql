insert /*+ APPEND */ into
 SUPPLIER
(
 "S_SUPPKEY"
,"S_NAME"
,"S_ADDRESS"
,"S_CITY"
,"S_NATION"
,"S_REGION"
,"S_PHONE"
)
select
 "S_SUPPKEY"
,RTRIM("S_NAME")
,"S_ADDRESS"
,RTRIM("S_CITY")
,RTRIM("S_NATION")
,RTRIM("S_REGION")
,RTRIM("S_PHONE")
from &src..SUPPLIER
where s_suppkey = 1
;
