/*
====================================================
Ticket 10: Monthly Customer Churn Analysis
====================================================

Business Question:
How many customers churned each month?

Business Context:
A customer is considered churned if they do not place an order in the immediately following month. Identifying churn trends helps the business evaluate customer retention and the effectiveness of engagement strategies.

KPI:
Monthly Churned Customers

Grain:
Intermediate:
One row = One customer per month

Final:
One row = One month with total churned customers

SQL Concepts Used:
- CTE
- Self Join
- LEFT JOIN
- Date Manipulation
- DATE_ADD()
- GROUP BY
====================================================
*/

WITH customer_month AS
(
    SELECT DISTINCT
           customer_id,
           DATE(order_date - INTERVAL (DAY(order_date)-1) DAY) AS month_start
    FROM orders
    WHERE order_status = 'Delivered'
),

customer_churn AS
(
    SELECT
        c1.customer_id,
        c1.month_start AS current_month,
        c2.month_start AS next_month
    FROM customer_month c1
    LEFT JOIN customer_month c2
        ON c1.customer_id = c2.customer_id
       AND c2.month_start = DATE_ADD(c1.month_start, INTERVAL 1 MONTH)
)

SELECT
    current_month,
    COUNT(customer_id) AS churned_customers
FROM customer_churn
WHERE next_month IS NULL
GROUP BY current_month
ORDER BY current_month;
