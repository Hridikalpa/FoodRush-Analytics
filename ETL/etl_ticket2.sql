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
Business Rules
====================================================

1. customer_id must not be NULL.
2. restaurant_id must not be NULL.
3. order_date must not be NULL.
4. order_amount must be greater than 0.
5. Only Delivered orders should be retained.

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

CREATE TABLE validated_orders AS

SELECT *
FROM raw_orders
WHERE customer_id IS NOT NULL
AND restaurant_id IS NOT NULL
AND order_date IS NOT NULL
AND CAST(order_amount AS DECIMAL(10,2)) > 0
AND order_status = 'Delivered';


/*
====================================================
Data Quality Validation
====================================================

Records Removed

✓ NULL Customer IDs
✓ NULL Restaurant IDs
✓ NULL Order Dates
✓ Orders with Amount <= 0
✓ Cancelled Orders

====================================================
====================================================
Interview Takeaway
====================================================

Q. Why create validated_orders instead of deleting bad rows
from raw_orders?

Answer:

Raw data should remain unchanged because it serves as the
original source of truth. Validation and transformation
should occur in downstream layers so the ETL pipeline can
be rerun, audited and modified without requiring the
original source file again.
