/*
====================================================
Ticket 3: Month-over-Month Revenue Growth
====================================================

Business Question:
How has revenue changed month over month?

KPI:
MoM Revenue Growth %

SQL Concepts:
- CTE
- LAG()
- Window Functions
- ROUND()

Tables:
orders
*/

with monthly_revenue as 
(select date_format(order_date, '%Y-%m') as yearmonth,
sum(order_amount) as revenue
from orders
where order_status = 'Delivered'
group by date_format(order_date, '%Y-%m')
order by date_format(order_date, '%Y-%m'))

select current_month,
current_revenue,
previous_revenue,
((current_revenue-previous_revenue)/previous_revenue) * 100 as MoM_rev_pct
from
(select yearmonth as current_month,
lag(yearmonth) over(order by yearmonth) as previous_month,
revenue as current_revenue,
lag(revenue) over(order by yearmonth) as previous_revenue
from monthly_revenue)m
