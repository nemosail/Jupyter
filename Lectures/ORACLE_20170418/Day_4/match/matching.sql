create or replace package matching
is
  procedure initialize;
  -- initialize by truncating all tables
  --
  procedure prematch_buy(p_src varchar2);
  procedure prematch_sell(p_src varchar2);
  -- Copy rows from p_src (an external table) to prematch 
  --
  -- When completed on both sides of the data, the real matching can take place
  --
  procedure match;
  -- Match data from the two prematch sides by moving matched rows 
  -- into the matched table.  Non matched rows are left in the
  -- source tables
  --
  --
end matching;
/
show errors
