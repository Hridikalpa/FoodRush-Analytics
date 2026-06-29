/*
====================================================
Ticket 4: Revenue Decomposition Analysis
====================================================

Business Question:
Is month-over-month revenue growth driven by changes
in order volume or Average Order Value (AOV)?

Key Formula:
Revenue = Orders × AOV

SQL Concepts:
- CTE
- LAG()
- Aggregation
- ROUND()
*/
with monthly_revenue as 
(select date_format(order_date, '%Y-%m') as yearmonth,
round(sum(order_amount),2) as revenue,
count(order_id) as orders,
round(avg(order_amount),2) as AOV
from orders
where order_status = 'Delivered'
group by date_format(order_date, '%Y-%m')
order by date_format(order_date, '%Y-%m')),

lag_data as (
select yearmonth as current_month,
revenue as current_revenue,
lag(revenue)over(order by yearmonth) as previous_revenue,
orders as current_orders,
lag(orders) over(order by yearmonth) as previous_orders,
AOV as current_aov,
lag(AOV)over(order by yearmonth) as previous_AOV
from monthly_revenue) 

select *,
round(((current_revenue-previous_revenue)/previous_revenue)*100,2) as mom_perc_change from lag_data
