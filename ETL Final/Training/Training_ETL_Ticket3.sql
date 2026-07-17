============================================================================================
============================================================================================
/*                   Ticket 3 — Data Validation & Quality Assurance                   */
============================================================================================
============================================================================================

=================================================================================
					    /* 3.1 Dataset Overview */
=================================================================================

SELECT COUNT(*) AS Total_rows
FROM clean_orders;

DESC clean_orders;

=================================================================================
					    /* 3.2 Completeness Validation */
=================================================================================

SELECT *
FROM clean_orders
WHERE
order_id IS NULL
OR customer_id IS NULL
OR restaurant_id IS NULL
OR order_date IS NULL
OR order_amount IS NULL
OR payment_mode IS NULL
OR order_status IS NULL;

=================================================================================
					    /* 3.3 Duplicate Validation */
=================================================================================

SELECT order_id, COUNT(*) AS duplicate_count
FROM clean_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

=================================================================================
					    /* 3.4 ID Validation */
=================================================================================

SELECT *
FROM clean_orders
WHERE
order_id NOT REGEXP '^[0-9]+$'
OR customer_id NOT REGEXP '^[0-9]+$'
OR restaurant_id NOT REGEXP '^[0-9]+$'
OR delivery_partner_id NOT REGEXP '^[0-9]+$';

=================================================================================
					    /* 3.5 Numeric Validation */
=================================================================================

SELECT *
FROM clean_orders
WHERE
order_amount<0
OR discount_amount<0
OR delivery_fee<0
OR food_cost<0
OR delivery_cost<0
OR tip_amount<0;

=================================================================================
					    /* 3.6 Date Validation */
=================================================================================

SELECT *
FROM clean_orders
WHERE
order_date IS NULL
OR delivery_date IS NULL
OR order_date > delivery_date;

=================================================================================
					    /* 3.7 Category Validation */
=================================================================================

SELECT DISTINCT payment_mode FROM clean_orders;

SELECT DISTINCT order_status FROM clean_orders;

SELECT DISTINCT platform FROM clean_orders;

=================================================================================
					    /* 3.8 Business Rule Validation */
=================================================================================

--------------------------------------------
/* Rule 1 (Order amount > Discount amount*/
--------------------------------------------
SELECT * FROM clean_orders
WHERE discount_amount > order_amount;

--------------------------------------------
/* Rule 2 (Customer rating between 1-5*/
--------------------------------------------
SELECT * FROM clean_orders
WHERE customer_rating NOT BETWEEN 1 AND 5;

=================================================================================
					    /* 3.9 Validation Summary*/
=================================================================================

SELECT
(SELECT COUNT(*) FROM rejected_missing_values) Missing_Records,
(SELECT COUNT(*) FROM rejected_invalid_ids) Invalid_IDs,
(SELECT COUNT(*) FROM rejected_invalid_numeric) Invalid_Numerics,
(SELECT COUNT(*) FROM rejected_invalid_dates) Invalid_Dates,
(SELECT COUNT(*) FROM rejected_duplicates) Duplicate_Records,
(SELECT COUNT(*) FROM rejected_discount_errors) Discount_Errors,
(SELECT COUNT(*) FROM rejected_invalid_ratings) Invalid_Ratings,
(SELECT COUNT(*) FROM clean_orders) Clean_Records;
