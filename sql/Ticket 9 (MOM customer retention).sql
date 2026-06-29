/*
====================================================
Ticket 9: Month-to-Month Customer Retention
====================================================

Business Question:
How many customers who purchased in one month returned to purchase in the immediately following month?

Business Context:
Customer retention is one of the most important KPIs for subscription, e-commerce, and food delivery businesses.
Instead of only acquiring new customers, businesses must understand whether existing customers continue purchasing month after month.

KPI:
Monthly Retention
A retained customer is one who places an order in both the current month and the immediately following month.

---

## Grain
### Intermediate Table
One row = One customer per month
| customer_id | month_start |
| customer_id | customer_name |

### Final Output
One row = One retained customer transition
| customer_id | current_month | retained_month |


---

## SQL Concepts Used

- Self Join
- LEAD()
- CTE
- DISTINCT
- DATE_ADD()
- Date Manipulation
====================================================
*/
/*
====================================================
Month-to-Month Customer Retention
(Self Join) sql
====================================================
*/

WITH customer_month AS
(
SELECT DISTINCT
       customer_id,
       DATE(order_date - INTERVAL (DAY(order_date)-1) DAY) AS month_start
FROM orders
WHERE order_status='Delivered'
)

SELECT
       cm1.customer_id,
       cm1.month_start AS current_month,
       cm2.month_start AS retained_month
FROM customer_month cm1
JOIN customer_month cm2
ON cm1.customer_id = cm2.customer_id
AND cm2.month_start = DATE_ADD(cm1.month_start,INTERVAL 1 MONTH);

/*
====================================================
Month-to-Month Customer Retention
(LEAD) sql
====================================================
*/

WITH customer_month AS
(
SELECT DISTINCT
       customer_id,
       DATE(order_date - INTERVAL (DAY(order_date)-1) DAY) AS month_start
FROM orders
WHERE order_status='Delivered'
),

customer_next_month AS
(
SELECT
       customer_id,
       month_start,
       LEAD(month_start)
       OVER(PARTITION BY customer_id
            ORDER BY month_start) AS next_month
FROM customer_month
)

SELECT *
FROM customer_next_month
WHERE next_month = DATE_ADD(month_start,INTERVAL 1 MONTH);







