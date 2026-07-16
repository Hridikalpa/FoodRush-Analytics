/*
====================================================
ETL Ticket 2: Build Validated Orders Table
====================================================

Business Problem:
The raw_orders table contains operational data received from source systems.
This data may contain incomplete or invalid records that should not be used
for reporting or downstream analytics.

Objective:
Create a validated_orders table by retaining only records that satisfy
the business validation rules while preserving the original raw data.


====================================================
ETL Process
====================================================

Source
↓

raw_orders

↓

Validation Rules

↓

validated_orders

====================================================
SQL Solution
====================================================
*/

DROP TABLE IF EXISTS clean_orders;
CREATE TABLE clean_orders AS
SELECT * FROM training_orders;

===================================================================================
/* 2.1 Missing Values & ID Cleaning */
===================================================================================
-----------------------------------------------------------------------------------
/* Cleaning Missing Values */
-----------------------------------------------------------------------------------
DROP TABLE IF EXISTS rejected_missing_values
CREATE TABLE rejected_missing_values AS
SELECT * FROM clean_orders
WHERE order_id IS NULL OR TRIM(order_id)=''
OR customer_id IS NULL OR TRIM(customer_id)=''
OR restaurant_id IS NULL OR TRIM(restaurant_id)=''
OR order_date IS NULL OR TRIM(order_date)=''
OR order_amount IS NULL OR TRIM(order_amount)=''
OR payment_mode IS NULL OR TRIM(payment_mode)=''
OR order_status IS NULL OR TRIM(order_status)='';

DELETE FROM clean_orders
WHERE order_id IS NULL OR TRIM(order_id)=''
OR customer_id IS NULL OR TRIM(customer_id)=''
OR restaurant_id IS NULL OR TRIM(restaurant_id)=''
OR order_date IS NULL OR TRIM(order_date)=''
OR order_amount IS NULL OR TRIM(order_amount)=''
OR payment_mode IS NULL OR TRIM(payment_mode)=''
OR order_status IS NULL OR TRIM(order_status)='';

-----------------------------------------------------------------------------------
/* Cleaning IDs */
-----------------------------------------------------------------------------------
DROP TABLE IF EXISTS rejected_invalid_ids
CREATE TABLE rejected_invalid_ids AS
SELECT * FROM clean_orders
WHERE order_id NOT REGEXP '^[0-9]+$'
OR customer_id NOT REGEXP '^[0-9]+$'
OR restaurant_id NOT REGEXP '^[0-9]+$'
OR delivery_partner_id NOT REGEXP '^[0-9]+$';

DELETE FROM clean_orders
WHERE order_id NOT REGEXP '^[0-9]+$'
OR customer_id NOT REGEXP '^[0-9]+$'
OR restaurant_id NOT REGEXP '^[0-9]+$'
OR delivery_partner_id NOT REGEXP '^[0-9]+$';

===================================================================================
/* 2.2 String Cleaning */
===================================================================================

UPDATE clean_orders
SET 
city=TRIM(city),area=TRIM(area),cuisine=TRIM(cuisine),
payment_mode=TRIM(payment_mode),order_status=TRIM(order_status),
restaurant_name=TRIM(restaurant_name),customer_name=TRIM(customer_name),
remarks=TRIM(remarks),coupon_code=TRIM(coupon_code),
platform=TRIM(platform),acquisition_channel=TRIM(acquisition_channel);

UPDATE clean_orders
SET
city = TRIM(REGEXP_REPLACE(city,'[[:space:]]+',' ')),
area = TRIM(REGEXP_REPLACE(area,'[[:space:]]+',' ')),
restaurant_name = TRIM(REGEXP_REPLACE(restaurant_name,'[[:space:]]+',' ')),
customer_name = TRIM(REGEXP_REPLACE(customer_name,'[[:space:]]+',' '));

UPDATE clean_orders
SET remarks=NULLIF(TRIM(remarks),''),
coupon_code=NULLIF(TRIM(coupon_code),''),
platform=NULLIF(TRIM(platform),''),
acquisition_channel=NULLIF(TRIM(acquisition_channel),'');

===================================================================================
/* 2.3 Category Standardization */
===================================================================================

SELECT DISTINCT(acquisition_channel) FROM clean_orders;
SELECT DISTINCT(payment_mode) FROM clean_orders;
SELECT DISTINCT(order_status) FROM clean_orders;
SELECT DISTINCT(platform) FROM clean_orders;

UPDATE clean_orders
SET payment_mode = 
CASE 
WHEN LOWER(payment_mode) = 'cash' THEN 'Cash'
WHEN LOWER(payment_mode) = 'wallet' THEN 'Wallet'
WHEN LOWER(payment_mode) = 'upi' THEN 'UPI'
WHEN LOWER(payment_mode) IN ('card','creditcard') THEN 'Card'
ELSE payment_mode END;

UPDATE clean_orders
SET order_status = 
CASE
WHEN LOWER(order_status) = 'cancelled' THEN 'Cancelled'
WHEN LOWER(order_status) = 'returned' THEN 'Returned'
WHEN LOWER(order_status) IN ('delivered','delivred') THEN 'Delivered'
ELSE order_status END;

===================================================================================
/* 2.4 Numeric Cleaning */
===================================================================================
UPDATE clean_orders
SET order_amount=TRIM(REPLACE(REPLACE(order_amount,'₹', ''),',','')),
discount_amount=TRIM(REPLACE(REPLACE(discount_amount,'₹',''),',','')),
delivery_fee=TRIM(REPLACE(REPLACE(delivery_fee,'₹',''),',','')),
food_cost=TRIM(REPLACE(REPLACE(food_cost,'₹',''),',','')),
delivery_cost=TRIM(REPLACE(REPLACE(delivery_cost,'₹',''),',','')),
tip_amount=TRIM(REPLACE(REPLACE(tip_amount,'₹',''),',',''));

DROP TABLE IF EXISTS rejected_invalid_numeric

CREATE TABLE IF NOT EXISTS rejected_invalid_numeric AS
SELECT * FROM clean_orders
WHERE order_amount NOT REGEXP '^[0-9]+(\.[0-9]{1,2})?$'
OR discount_amount NOT REGEXP '^[0-9]+(\.[0-9]{1,2})?$';

DELETE FROM clean_orders
WHERE order_amount NOT REGEXP '^[0-9]+(\.[0-9]{1,2})?$'
OR discount_amount NOT REGEXP '^[0-9]+(\.[0-9]{1,2})?$';

===================================================================================
/* 2.5 Date Cleaning */
===================================================================================

UPDATE clean_orders
SET order_date=TRIM(REPLACE(REPLACE(order_date,'/','-'),'.','-')),
delivery_date=TRIM(REPLACE(REPLACE(delivery_date,'/','-'),'.','-'));

DROP TABLE IF EXISTS rejected_invalid_dates

CREATE TABLE rejected_invalid_dates AS
SELECT *
FROM clean_orders
WHERE

order_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
OR SUBSTRING(order_date,6,2) NOT BETWEEN '01' AND '12'
OR SUBSTRING(order_date,9,2) NOT BETWEEN '01' AND '31';

DELETE FROM clean_orders
WHERE
order_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
OR SUBSTRING(order_date,6,2) NOT BETWEEN '01' AND '12'
OR SUBSTRING(order_date,9,2) NOT BETWEEN '01' AND '31';

===================================================================================
/* 2.6 Duplicate Removal */
===================================================================================

/*Detect Duplicate Order IDs*/

SELECT
order_id,
COUNT(*) AS duplicate_count
FROM clean_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

/*Archive Duplicate Records*/
DROP TABLE IF EXISTS rejected_duplicates

CREATE TABLE rejected_duplicates AS

SELECT *
FROM clean_orders

WHERE order_id IN
(SELECT order_id
FROM
(SELECT order_id
FROM clean_orders
GROUP BY order_id
HAVING COUNT(*) > 1) d);

/*Removing Duplicate Records*/

ALTER TABLE clean_orders
ADD COLUMN etl_row_id INT AUTO_INCREMENT PRIMARY KEY;

DELETE c1
FROM clean_orders c1
join clean_orders c2
on c1.order_id = c2.order_id
AND c1.etl_row_id > c2.etl_row_id;

/*Validate Deletion*/

SELECT
order_id,
COUNT(*) AS duplicate_count
FROM clean_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

===================================================================================
/* 2.7 Business Rules Validation and Cleaning */
===================================================================================
-----------------------------------------------------------------------------------
/* Rule 1: Discount cannot exceed order amount */
-----------------------------------------------------------------------------------
/* Archive */
DROP TABLE IF EXISTS rejected_discount_errors
CREATE TABLE rejected_discount_errors AS
SELECT *
FROM clean_orders
WHERE
CAST(discount_amount AS DECIMAL(10,2)) > CAST(order_amount AS DECIMAL(10,2));

/* Delete */

DELETE
FROM clean_orders
WHERE
CAST(discount_amount AS DECIMAL(10,2)) > CAST(order_amount AS DECIMAL(10,2));

-----------------------------------------------------------------------------------
/* Rule 2: Customer Rating */
-----------------------------------------------------------------------------------
/* Archive */
DROP TABLE IF EXISTS rejected_invalid_ratings
CREATE TABLE rejected_invalid_ratings AS
SELECT *
FROM clean_orders
WHERE
CAST(customer_rating AS DECIMAL(3,1))
NOT BETWEEN 1 AND 5;

/* Delete */

DELETE
FROM clean_orders
WHERE
CAST(customer_rating AS DECIMAL(3,1))
NOT BETWEEN 1 AND 5;

/* Business Rule Validation */

/* Rule 1 */
SELECT *
FROM clean_orders
WHERE
CAST(discount_amount AS DECIMAL(10,2))
>
CAST(order_amount AS DECIMAL(10,2));
/* Rule 2 */
SELECT *
FROM clean_orders
WHERE
CAST(customer_rating AS DECIMAL(3,1))
NOT BETWEEN 1 AND 5;

===================================================================================
/* 2.8 Data Type Conversion */
===================================================================================

ALTER TABLE clean_orders
MODIFY order_id INT,
MODIFY customer_id INT,
MODIFY restaurant_id INT,
MODIFY delivery_partner_id INT,

MODIFY order_amount DECIMAL(10,2),
MODIFY discount_amount DECIMAL(10,2),
MODIFY delivery_fee DECIMAL(10,2),
MODIFY food_cost DECIMAL(10,2),
MODIFY delivery_cost DECIMAL(10,2),
MODIFY tip_amount DECIMAL(10,2),

MODIFY customer_rating DECIMAL(2,1),

MODIFY order_date DATETIME,
MODIFY delivery_date DATETIME;

===================================================================================
/* 2.9 Final Validation */
===================================================================================

DESC clean_orders;

SELECT COUNT(*) FROM rejected_missing_values;
SELECT COUNT(*) FROM rejected_invalid_ids;
SELECT COUNT(*) FROM rejected_invalid_numeric;
SELECT COUNT(*) FROM rejected_invalid_dates;
SELECT COUNT(*) FROM rejected_duplicates;

/*
