/*
====================================================
Ticket 2: Repeat Customer Rate by City
====================================================

Business Question:
Which cities have the highest repeat customer rate?

KPI:
Repeat Customer Rate =
Repeat Customers / Total Customers × 100

Grain:
CTE1  -> One row per customer
Final -> One row per city

*/

with customer_ordercount as
(select c.customer_id, c.city, count(o.order_id) as order_count
from customers c
join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Delivered'
group by c.customer_id, c.city),
recurring_customers as
(select customer_id, city,
case when order_count > 1 then 1
else 0 end as repeat_flag
from customer_ordercount)

select city,
count(customer_id) as total_customers,
sum(repeat_flag) as repeat_customers,
(sum(repeat_flag)/count(customer_id))*100 as repeat_rate  from recurring_customers
group by city
