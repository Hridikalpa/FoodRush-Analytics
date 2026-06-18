/*
Ticket 1

Business Question:
Which acquisition channel acquires the highest-value customers?

Metric:
Average Lifetime Spend per Customer

Only Delivered orders considered.
*/
select acquisition_channel, count(customer_id) as total_customers,
round(sum(lifetime_spend)/count(customer_id),2) as avg_lifetime_spend,
sum(lifetime_spend) as total_lifetime_revenue
from
(select c.customer_id, c.acquisition_channel , sum(o.order_amount) as lifetime_spend
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status = 'Delivered'
group by c.customer_id, c.acquisition_channel) c
group by acquisition_channel
order by (sum(lifetime_spend)/count(customer_id)) desc, sum(lifetime_spend) desc
