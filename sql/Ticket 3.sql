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

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS yearmonth,
        SUM(order_amount) AS revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    yearmonth AS current_month,
    revenue AS current_revenue,
    LAG(revenue) OVER (ORDER BY yearmonth) AS previous_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY yearmonth))
            / LAG(revenue) OVER (ORDER BY yearmonth)) * 100,2) AS mom_revenue_pct
FROM monthly_revenue;
