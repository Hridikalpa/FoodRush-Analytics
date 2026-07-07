/*
===============================================================================
FoodRush Analytics
Training ETL

Ticket 1 : Data Quality Assessment
===============================================================================

Business Objective
------------------
Before performing any transformation, assess the quality of the raw data.

The objective is to identify missing values, duplicate records, invalid formats,
inconsistent values and business rule violations.

No data is modified in this ticket.

Input Table
-----------
raw_orders

Output
------
Data Quality Assessment Report

===============================================================================
*/


USE ETL_TRAINING;



/*=============================================================================
1. Dataset Overview
=============================================================================*/

-- Total Rows

SELECT COUNT(*) AS total_rows
FROM training_orders;


-- Total Columns

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema='etl_training'
AND table_name='training_orders';


-- Structure of the table

DESC training_orders;



/*=============================================================================
2. Completeness Check
Checking NULL values and Blank values
=============================================================================*/

SELECT

SUM(order_id IS NULL OR order_id='')                    AS order_id,

SUM(customer_id IS NULL OR customer_id='')             AS customer_id,

SUM(restaurant_id IS NULL OR restaurant_id='')         AS restaurant_id,

SUM(delivery_partner_id IS NULL OR delivery_partner_id='') AS delivery_partner_id,

SUM(order_date IS NULL OR order_date='')               AS order_date,

SUM(delivery_date IS NULL OR delivery_date='')         AS delivery_date,

SUM(city IS NULL OR city='')                           AS city,

SUM(area IS NULL OR area='')                           AS area,

SUM(cuisine IS NULL OR cuisine='')                     AS cuisine,

SUM(acquisition_channel IS NULL OR acquisition_channel='') AS acquisition_channel,

SUM(payment_mode IS NULL OR payment_mode='')           AS payment_mode,

SUM(order_status IS NULL OR order_status='')           AS order_status,

SUM(order_amount IS NULL OR order_amount='')           AS order_amount,

SUM(discount_amount IS NULL OR discount_amount='')     AS discount_amount,

SUM(delivery_fee IS NULL OR delivery_fee='')           AS delivery_fee,

SUM(delivery_time_min IS NULL OR delivery_time_min='') AS delivery_time_min,

SUM(food_cost IS NULL OR food_cost='')                 AS food_cost,

SUM(delivery_cost IS NULL OR delivery_cost='')         AS delivery_cost,

SUM(customer_rating IS NULL OR customer_rating='')     AS customer_rating,

SUM(coupon_code IS NULL OR coupon_code='')             AS coupon_code,

SUM(tip_amount IS NULL OR tip_amount='')               AS tip_amount,

SUM(platform IS NULL OR platform='')                   AS platform,

SUM(restaurant_name IS NULL OR restaurant_name='')     AS restaurant_name,

SUM(customer_name IS NULL OR customer_name='')         AS customer_name,

SUM(remarks IS NULL OR remarks='')                     AS remarks

FROM training_orders;



-- Display rows containing important missing values

SELECT *
FROM training_orders
WHERE

order_id IS NULL OR order_id=''
OR customer_id IS NULL OR customer_id=''
OR restaurant_id IS NULL OR restaurant_id=''
OR delivery_partner_id IS NULL OR delivery_partner_id=''
OR order_date IS NULL OR order_date=''
OR delivery_date IS NULL OR delivery_date=''
OR payment_mode IS NULL OR payment_mode=''
OR order_status IS NULL OR order_status=''
OR order_amount IS NULL OR order_amount='';



/*=============================================================================
3. Uniqueness Check
=============================================================================*/

-- Duplicate Primary Key

SELECT

order_id,
COUNT(*) AS duplicate_count

FROM training_orders

GROUP BY order_id

HAVING COUNT(*) > 1;



-- Duplicate Complete Records

SELECT

order_id,
customer_id,
restaurant_id,
delivery_partner_id,
order_date,
delivery_date,
city,
area,
cuisine,
acquisition_channel,
payment_mode,
order_status,
order_amount,
discount_amount,
delivery_fee,
delivery_time_min,
food_cost,
delivery_cost,
customer_rating,
coupon_code,
tip_amount,
platform,
restaurant_name,
customer_name,
remarks,

COUNT(*) AS duplicate_count

FROM training_orders

GROUP BY

order_id,
customer_id,
restaurant_id,
delivery_partner_id,
order_date,
delivery_date,
city,
area,
cuisine,
acquisition_channel,
payment_mode,
order_status,
order_amount,
discount_amount,
delivery_fee,
delivery_time_min,
food_cost,
delivery_cost,
customer_rating,
coupon_code,
tip_amount,
platform,
restaurant_name,
customer_name,
remarks

HAVING COUNT(*) > 1;



/*=============================================================================
4. Validity Check
=============================================================================*/

-- Invalid IDs

SELECT *

FROM training_orders

WHERE

order_id IS NULL
OR order_id=''
OR order_id='0'
OR order_id LIKE '-%'
OR order_id NOT REGEXP '^[0-9]+$'

OR customer_id IS NULL
OR customer_id=''
OR customer_id='0'
OR customer_id LIKE '-%'
OR customer_id NOT REGEXP '^[0-9]+$'

OR restaurant_id IS NULL
OR restaurant_id=''
OR restaurant_id='0'
OR restaurant_id LIKE '-%'
OR restaurant_id NOT REGEXP '^[0-9]+$'

OR delivery_partner_id IS NULL
OR delivery_partner_id=''
OR delivery_partner_id='0'
OR delivery_partner_id LIKE '-%'
OR delivery_partner_id NOT REGEXP '^[0-9]+$';

/*=============================================================================
Numeric Validation
Checking whether numeric columns contain only valid numeric values.
This check is performed before applying CAST().
=============================================================================*/

SELECT *

FROM training_orders

WHERE

order_amount NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'

OR discount_amount NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'

OR delivery_fee NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'

OR food_cost NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'

OR delivery_cost NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'

OR tip_amount NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$';
/*=============================================================================
Date Format Validation
Checks whether dates follow YYYY-MM-DD format.
=============================================================================*/

SELECT *

FROM training_orders

WHERE

order_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'

OR

delivery_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

/*=============================================================================
Calendar Validation
Checks whether the dates are valid calendar dates.
=============================================================================*/

SELECT *

FROM training_orders

WHERE

STR_TO_DATE(order_date,'%Y-%m-%d') IS NULL

OR

STR_TO_DATE(delivery_date,'%Y-%m-%d') IS NULL;



/*=============================================================================
5. Category Profiling
=============================================================================*/

SELECT

'City' AS Column_Name,

city AS Category,

COUNT(*) AS Total,

ROUND(
COUNT(*)*100.0/
(SELECT COUNT(*) FROM training_orders),2
) AS Percentage

FROM training_orders

GROUP BY city

UNION ALL

SELECT

'Cuisine',

cuisine,

COUNT(*),

ROUND(
COUNT(*)*100.0/
(SELECT COUNT(*) FROM training_orders),2
)

FROM training_orders

GROUP BY cuisine

UNION ALL

SELECT

'Acquisition Channel',

acquisition_channel,

COUNT(*),

ROUND(
COUNT(*)*100.0/
(SELECT COUNT(*) FROM training_orders),2
)

FROM training_orders

GROUP BY acquisition_channel

UNION ALL

SELECT

'Payment Mode',

payment_mode,

COUNT(*),

ROUND(
COUNT(*)*100.0/
(SELECT COUNT(*) FROM training_orders),2
)

FROM training_orders

GROUP BY payment_mode

UNION ALL

SELECT

'Order Status',

order_status,

COUNT(*),

ROUND(
COUNT(*)*100.0/
(SELECT COUNT(*) FROM training_orders),2
)

FROM training_orders

GROUP BY order_status

ORDER BY Column_Name;



/*=============================================================================
6. String Quality Check
=============================================================================*/

-- Leading / Trailing Spaces

SELECT *

FROM training_orders

WHERE

city <> TRIM(city)

OR cuisine <> TRIM(cuisine)

OR payment_mode <> TRIM(payment_mode)

OR restaurant_name <> TRIM(restaurant_name)

OR customer_name <> TRIM(customer_name);

/*=============================================================================
Multiple Consecutive Spaces
=============================================================================*/

SELECT *

FROM training_orders

WHERE

city REGEXP '[[:space:]]{2,}'

OR cuisine REGEXP '[[:space:]]{2,}'

OR customer_name REGEXP '[[:space:]]{2,}'

OR restaurant_name REGEXP '[[:space:]]{2,}';

/*=============================================================================
Tab Characters
=============================================================================*/

SELECT *

FROM training_orders

WHERE

city REGEXP '\t'

OR customer_name REGEXP '\t'

OR restaurant_name REGEXP '\t';

/*=============================================================================
Unexpected Special Characters
=============================================================================*/

SELECT *

FROM training_orders

WHERE

restaurant_name REGEXP '[^A-Za-z0-9 &.-]';



/*=============================================================================
7. Numeric Profiling
=============================================================================*/

SELECT

MIN(order_amount),
AVG(order_amount),
MAX(order_amount),

MIN(discount_amount),
AVG(discount_amount),
MAX(discount_amount),

MIN(delivery_fee),
AVG(delivery_fee),
MAX(delivery_fee),

MIN(food_cost),
AVG(food_cost),
MAX(food_cost),

MIN(delivery_cost),
AVG(delivery_cost),
MAX(delivery_cost)

FROM training_orders;



/*=============================================================================
8. Business Rule Validation
=============================================================================*/

-- Discount should never exceed Order Amount

SELECT *

FROM training_orders

WHERE

CAST(discount_amount AS DECIMAL(10,2))
>
CAST(order_amount AS DECIMAL(10,2));

-- Delivery date should not be before Order Date 

SELECT *

FROM training_orders

WHERE

STR_TO_DATE(delivery_date,'%Y-%m-%d')

<

STR_TO_DATE(order_date,'%Y-%m-%d');

-- Rating should be between 1 and 5

SELECT *

FROM training_orders

WHERE

customer_rating NOT BETWEEN 1 AND 5;

/*=============================================================================
10. Data Quality Summary
=============================================================================*/

SELECT

COUNT(*) AS Total_Rows,

SUM(order_id IS NULL OR order_id='') AS Missing_Order_ID,

SUM(customer_id IS NULL OR customer_id='') AS Missing_Customer_ID,

SUM(payment_mode IS NULL OR payment_mode='') AS Missing_Payment_Mode,

SUM(order_status IS NULL OR order_status='') AS Missing_Order_Status

FROM training_orders;

/*=============================================================================
End of Ticket 1
=============================================================================*/
