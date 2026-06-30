/*
====================================================
ETL Ticket 1: Data Profiling & Data Quality Assessment
====================================================

Business Problem:
FoodRush receives raw order data from multiple operational systems every day.
Before transforming or loading the data into the warehouse, we need to assess
its quality and identify potential issues.

Objective:
Profile the raw dataset and identify data quality issues without modifying
the data.

====================================================
Business Rules
====================================================

1. order_id should be unique.
2. customer_id should not be NULL.
3. restaurant_id should not be NULL.
4. order_date should be present and valid.
5. order_amount should normally be greater than zero.
6. Every order should belong to a valid customer.
7. Every order should belong to a valid restaurant.

====================================================
Data Profiling Checks
====================================================
*/

-- ==========================================
-- 1. Total Row Count
-- ==========================================

SELECT COUNT(*) AS total_rows
FROM raw_orders;

-- ==========================================
-- 2. Duplicate Rows
-- ==========================================

SELECT *,
COUNT(*) AS duplicate_count
FROM raw_orders
GROUP BY
order_id,
customer_id,
restaurant_id,
order_date,
order_amount,
order_status,
acquisition_channel
HAVING COUNT(*) > 1;

-- ==========================================
-- 3. Duplicate Primary Keys
-- ==========================================

SELECT
order_id,
COUNT(*) AS occurrences
FROM raw_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- ==========================================
-- 4. NULL Analysis
-- ==========================================

SELECT
SUM(order_id IS NULL) AS null_order_id,
SUM(customer_id IS NULL) AS null_customer_id,
SUM(restaurant_id IS NULL) AS null_restaurant_id,
SUM(order_date IS NULL) AS null_order_date,
SUM(order_amount IS NULL) AS null_order_amount,
SUM(order_status IS NULL) AS null_order_status,
SUM(acquisition_channel IS NULL) AS null_acquisition_channel
FROM raw_orders;

-- ==========================================
-- 5. Invalid Dates
-- ==========================================

SELECT *
FROM raw_orders
WHERE STR_TO_DATE(order_date,'%Y-%m-%d') IS NULL;

-- ==========================================
-- 6. Negative Amount
-- ==========================================

SELECT *
FROM raw_orders
WHERE CAST(order_amount AS DECIMAL(10,2)) < 0;

-- ==========================================
-- 7. Zero Amount
-- ==========================================

SELECT *
FROM raw_orders
WHERE CAST(order_amount AS DECIMAL(10,2)) = 0;

-- ==========================================
-- 8. Outlier Detection
-- ==========================================

SELECT
MIN(CAST(order_amount AS DECIMAL(10,2))) AS min_amount,
MAX(CAST(order_amount AS DECIMAL(10,2))) AS max_amount,
AVG(CAST(order_amount AS DECIMAL(10,2))) AS avg_amount
FROM raw_orders;

SELECT *
FROM raw_orders
ORDER BY CAST(order_amount AS DECIMAL(10,2)) DESC;

-- ==========================================
-- 9. Business Rule Review
-- ==========================================

/*
Review manually:

- Cancelled orders
- Negative amount
- Zero amount
- Extremely high amount
- Missing customer
- Missing restaurant
- Invalid date

These require discussion with the business before deciding
whether to reject, correct or retain the records.
*/

-- ==========================================
-- 10. Referential Integrity
-- ==========================================


SELECT r.*
FROM raw_orders r
LEFT JOIN customers c
ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT r.*
FROM raw_orders r
LEFT JOIN restaurants rs
ON r.restaurant_id = rs.restaurant_id
WHERE rs.restaurant_id IS NULL;

/*
====================================================
Findings
====================================================

Issues Identified

✓ Duplicate Rows
✓ Duplicate Primary Keys
✓ NULL Customer IDs
✓ NULL Restaurant IDs
✓ NULL Order Dates
✓ Invalid Date Format
✓ Negative Order Amount
✓ Zero Order Amount
✓ Suspiciously High Order Amount

====================================================

