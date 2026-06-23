/*
====================================================
Ticket 7: Customers Spending Above Their City's Average
====================================================

Business Question:
Identify customers whose lifetime spending exceeds the average customer spending within their own city.

Business Context:
Not all customers contribute equally to revenue.

By comparing each customer's spending against the average spending of customers within the same city, the business can identify high-value customers for targeted retention and loyalty initiatives.

KPI:
### Customer Revenue

Customer Revenue = SUM(order_amount)

(Considering Delivered orders only.)

### City Average Customer Revenue

City Average Revenue =
Average(Customer Revenue) within each city

---

## Grain

### Intermediate Table

One row represents one customer.

| city | customer_id | revenue |

### Final Output

One row represents one customer whose revenue exceeds the city average.

| city | customer_id | revenue | city_avg_revenue |

---

## SQL Concepts Used

- CTE
- INNER JOIN
- GROUP BY
- Window Functions
- AVG() OVER()
- PARTITION BY
====================================================
*/

With customer_revenue as 
(SELECT c.city, c.customer_id, sum(o.order_amount) as revenue
from customers c
join orders o
on c.customer_id=o.customer_id
where o.order_status = 'Delivered'
group by c.city, c.customer_id)


select * from
(select city, customer_id, revenue , round (avg(revenue) over(partition by city),2) as avg_revenue 
from customer_revenue)c
where revenue > avg_revenue
