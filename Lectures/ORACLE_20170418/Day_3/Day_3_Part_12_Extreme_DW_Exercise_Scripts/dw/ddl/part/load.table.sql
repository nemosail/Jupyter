insert /*+ APPEND */ into
 PART
(
 "P_PARTKEY"
,"P_NAME"
,"P_MFGR"
,"P_CATEGORY"
,"P_BRAND1"
,"P_COLOR"
,"P_TYPE"
,"P_SIZE"
,"P_CONTAINER"
)
select
 "P_PARTKEY"
,"P_NAME"
,RTRIM("P_MFGR")
,RTRIM("P_CATEGORY")
,RTRIM("P_BRAND1")
,"P_COLOR"
,"P_TYPE"
,"P_SIZE"
,RTRIM("P_CONTAINER")
from
 &src..PART
;