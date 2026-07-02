/*
============================================================
ETL Production Ticket 2 : Data Profiling Report
============================================================

Business Problem
----------------
Before transforming operational data into a warehouse,
the incoming dataset must be profiled to understand
its quality.

Data profiling helps identify:

• Missing values
• Duplicate records
• Invalid primary keys
• Distribution of categorical values
• Numerical ranges
• Potential outliers

No data is modified during this stage.

ETL Layer
---------
Data Profiling

Input
-----
raw_orders

Output
------
Data Quality Report

============================================================
1. Row Count
============================================================
*/

SELECT COUNT(*) AS total_records
FROM raw_orders_prod;


/*
============================================================
2. NULL Value Analysis
============================================================
*/

SELECT
SUM(order_id IS NULL) AS null_order_id,
SUM(customer_id IS NULL) AS null_customer_id,
SUM(restaurant_id IS NULL) AS null_restaurant_id,
SUM(order_date IS NULL) AS null_order_date,
SUM(city IS NULL) AS null_city,
SUM(order_amount IS NULL) AS null_order_amount,
SUM(discount_amount IS NULL) AS null_discount_amount,
SUM(delivery_fee IS NULL) AS null_delivery_fee,
SUM(payment_mode IS NULL) AS null_payment_mode,
SUM(order_status IS NULL) AS null_order_status,
SUM(delivery_time_min IS NULL) AS null_delivery_time_min,
SUM(food_cost IS NULL) AS null_food_cost,
SUM(delivery_cost IS NULL) AS null_delivery_cost
FROM raw_orders_prod;


/*
============================================================
3. Duplicate Primary Key Check
============================================================
*/

SELECT
order_id,
COUNT(*) AS duplicate_count
FROM raw_orders_prod
GROUP BY order_id
HAVING COUNT(*) > 1;


/*
============================================================
4. Primary Key Validation
============================================================
*/

SELECT *
FROM raw_orders_prod
WHERE order_id <= 0
OR customer_id <= 0
OR restaurant_id <= 0;


/*
============================================================
5. Numeric Summary Statistics
============================================================
*/

SELECT

MIN(order_amount) AS min_order_amount,
AVG(order_amount) AS avg_order_amount,
MAX(order_amount) AS max_order_amount,

MIN(discount_amount) AS min_discount,
AVG(discount_amount) AS avg_discount,
MAX(discount_amount) AS max_discount,

MIN(delivery_fee) AS min_delivery_fee,
AVG(delivery_fee) AS avg_delivery_fee,
MAX(delivery_fee) AS max_delivery_fee,

MIN(food_cost) AS min_food_cost,
AVG(food_cost) AS avg_food_cost,
MAX(food_cost) AS max_food_cost,

MIN(delivery_cost) AS min_delivery_cost,
AVG(delivery_cost) AS avg_delivery_cost,
MAX(delivery_cost) AS max_delivery_cost

FROM raw_orders_prod;


/*
============================================================
6. City Distribution
============================================================
*/

SELECT
city,
COUNT(*) AS total_orders
FROM raw_orders_prod
GROUP BY city
ORDER BY total_orders DESC;


/*
============================================================
7. Payment Mode Distribution
============================================================
*/

SELECT
payment_mode,
COUNT(*) AS total_orders
FROM raw_orders_prod
GROUP BY payment_mode
ORDER BY total_orders DESC;


/*
============================================================
8. Order Status Distribution
============================================================
*/

SELECT
order_status,
COUNT(*) AS total_orders
FROM raw_orders_prod
GROUP BY order_status
ORDER BY total_orders DESC;


/*
============================================================
9. Basic Date Validation
============================================================
*/

SELECT
MIN(order_date) AS first_order,
MAX(order_date) AS latest_order
FROM raw_orders_prod;


/*
============================================================
Findings
============================================================

 Checked total row count

 Checked NULL values

 Checked duplicate Order IDs

 Checked invalid Primary Keys

 Analysed numeric ranges

 Analysed city distribution

 Analysed payment mode distribution

 Analysed order status distribution

 Reviewed date range

No transformations were performed during this stage.

============================================================
Business Impact
============================================================

Data Profiling provides an overview of the quality of
incoming operational data before any transformations
are applied.

This step helps identify potential issues early and
reduces downstream data quality problems.

============================================================
Interview Takeaway
============================================================

Q. Why perform Data Profiling before Data Cleaning?

Answer:

Data Profiling helps understand the quality of incoming
data before making any changes. Instead of assuming what
needs to be cleaned, we first measure missing values,
duplicates, invalid keys and distributions. Cleaning
rules are then based on evidence rather than assumptions.
