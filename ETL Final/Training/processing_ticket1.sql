/* Training ETL - Ticket 1 : Data Quality Assessment */

SELECT COUNT(*) AS total_rows FROM training_orders;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema='etl_training'
AND table_name='training_orders';

-- Missing values / empty strings
SELECT *
FROM training_orders
WHERE
order_id IS NULL OR order_id='' OR
customer_id IS NULL OR customer_id='' OR
restaurant_id IS NULL OR restaurant_id='' OR
delivery_partner_id IS NULL OR delivery_partner_id='' OR
order_date IS NULL OR order_date='' OR
delivery_date IS NULL OR delivery_date='' OR
city IS NULL OR city='' OR
area IS NULL OR area='' OR
cuisine IS NULL OR cuisine='' OR
acquisition_channel IS NULL OR acquisition_channel='' OR
payment_mode IS NULL OR payment_mode='' OR
order_status IS NULL OR order_status='' OR
order_amount IS NULL OR order_amount='' OR
discount_amount IS NULL OR discount_amount='' OR
delivery_fee IS NULL OR delivery_fee='' OR
delivery_time_min IS NULL OR delivery_time_min='' OR
customer_rating IS NULL OR customer_rating='' OR
tip_amount IS NULL OR tip_amount='';

-- Duplicate PK
SELECT order_id,COUNT(*) AS duplicate_count
FROM training_orders
GROUP BY order_id
HAVING COUNT(*)>1;

-- Invalid IDs
SELECT *
FROM training_orders
WHERE
order_id IS NULL OR order_id='' OR order_id='0' OR order_id LIKE '-%%' OR order_id NOT REGEXP '^[0-9]+$'
OR customer_id IS NULL OR customer_id='' OR customer_id='0' OR customer_id LIKE '-%%' OR customer_id NOT REGEXP '^[0-9]+$'
OR restaurant_id IS NULL OR restaurant_id='' OR restaurant_id='0' OR restaurant_id LIKE '-%%' OR restaurant_id NOT REGEXP '^[0-9]+$'
OR delivery_partner_id IS NULL OR delivery_partner_id='' OR delivery_partner_id='0' OR delivery_partner_id LIKE '-%%' OR delivery_partner_id NOT REGEXP '^[0-9]+$';

-- Numeric profiling
SELECT
MIN(order_amount),AVG(order_amount),MAX(order_amount),
MIN(discount_amount),AVG(discount_amount),MAX(discount_amount),
MIN(delivery_fee),AVG(delivery_fee),MAX(delivery_fee)
FROM training_orders;

-- Date format profiling
SELECT *
FROM training_orders
WHERE order_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Category distribution
SELECT 'Payment Mode' AS column_name,payment_mode AS value,COUNT(*) AS total
FROM training_orders GROUP BY payment_mode
UNION ALL
SELECT 'Order Status',order_status,COUNT(*)
FROM training_orders GROUP BY order_status
UNION ALL
SELECT 'City',city,COUNT(*)
FROM training_orders GROUP BY city;

-- Business rules
SELECT *
FROM training_orders
WHERE discount_amount>order_amount
OR delivery_fee<0
OR customer_rating NOT BETWEEN 1 AND 5;
