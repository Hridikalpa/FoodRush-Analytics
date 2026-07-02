/*
====================================================
ETL Production Ticket 1 : Extract Source Data
====================================================

Business Problem
----------------
FoodRush receives operational data from the production
database every day.

The first responsibility of the ETL pipeline is to
extract the source data into the ETL environment
without modifying it.

ETL Layer
---------
Extract

Input
-----
orders

Output
------
raw_orders

SQL Solution
====================================================
*/
create table raw_orders_Prod as
select * from foodrush_analytics.orders
/*
====================================================
Validation
====================================================
*/
select count(*) from foodrush_analytics.orders
select count(*) from raw_orders_Prod

/*Expected Result:
Both tables should have the same number of rows.

====================================================
Interview Takeaway
====================================================

Q. Why create raw_orders instead of using orders directly?

Answer:

The raw layer preserves an untouched copy of the source
data. It allows the ETL process to be rerun, audited and
debugged without affecting the original operational data.


