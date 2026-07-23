/*=========================================================
 Ticket 11
 Customer Purchase Behavior Analysis using Window Functions
=========================================================
Business Question:
Understanding individual customers' purchasing behavior changes over time.

Business Questions Answered:
What did the customer spend in their previous purchase?
What did the customer spend in their next purchase?
What was the customer's very first purchase?
What is the customer's latest purchase?

SQL Concepts Used:
- INNER JOIN
- Window Functions
- LAG()
- LEAD()
- FIRST_VALUE()
- LAST_VALUE()
==================================================*/

SELECT

    c.customer_id,
 
    c.customer_name,

    o.order_date,

    o.order_amount AS current_amount,

    LAG(o.order_amount)OVER(PARTITION BY c.customer_idORDER BY o.order_date) AS previous_amount,

    LEAD(o.order_amount)OVER(PARTITION BY c.customer_idORDER BY o.order_date) AS next_amount,

    FIRST_VALUE(o.order_amount)OVER(PARTITION BY c.customer_id ORDER BY o.order_date) AS first_purchase,

    LAST_VALUE(o.order_amount)OVER(PARTITION BY c.customer_id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_purchase

FROM customers c

INNER JOIN orders o
ON c.customer_id = o.customer_id

ORDER BY
c.customer_id,
o.order_date;
