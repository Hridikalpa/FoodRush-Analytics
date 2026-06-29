/*
====================================================
Ticket 8: Customers Without Delivered Orders
====================================================

Business Question:
Which customers have registered on the platform but never placed a delivered order?

Business Context:
Not all registered users become paying customers. Identifying customers who never completed a successful purchase helps improve activation and conversion rates.

KPI:
Delivered Customer
A customer with at least one order where:
order_status = 'Delivered'
---

## Grain
### Intermediate
One row = One customer
| customer_id | customer_name |

### Final Output
One row = One customer who has never placed a delivered order.
| customer_id | customer_name |

---

## SQL Concepts Used

- LEFT JOIN
- Anti Join Pattern
- NULL Filtering
- Join Conditions
====================================================
*/

SELECT
    c.customer_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
AND o.order_status = 'Delivered'
WHERE o.order_id IS NULL;
