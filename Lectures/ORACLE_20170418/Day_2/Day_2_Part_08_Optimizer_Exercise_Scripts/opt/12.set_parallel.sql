@alter.session.sql

alter table CUSTOMER parallel 4;
alter table DATE_DIM parallel 4;
alter table LINEORDER parallel 4;
alter table PART parallel 4;
alter table PROMOTION parallel 4;
alter table SUPPLIER parallel 4;

alter index LO_ORDERDATE parallel 4;
alter index LO_SUPPLIER parallel 4;
alter index LO_CUSTOMER parallel 4;
alter index LO_PART parallel 4;
alter index LO_PROMOTION parallel 4;
alter index SUPPLIER_PK parallel 4;
alter index PART_PK parallel 4;
alter index DATE_DIM_PK parallel 4;
alter index CUSTOMER_PK parallel 4;

