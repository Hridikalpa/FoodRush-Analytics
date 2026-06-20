/*
====================================================
Ticket 5: Top 3 Customers by Revenue Within Each City
====================================================

Business Question:
Identify the top 3 revenue-generating customers in each city to support VIP targeting and customer retention initiatives.


Key Formula:
Customer Revenue = SUM(order_amount)
(Considering Delivered orders only.)

SQL Concepts:
- JOIN
- GROUP BY
- Aggregate Functions (`SUM`)
- Window Function (`DENSE_RANK`)
- `PARTITION BY`
- Subquery
*/

SELECT city, customer_name, revenue
FROM (
    SELECT
        c.city,
        c.customer_id,
        c.customer_name,
        SUM(o.order_amount) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY SUM(o.order_amount) DESC
        ) AS rank_
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city, c.customer_id, c.customer_name
) c
WHERE rank_ <= 3;
