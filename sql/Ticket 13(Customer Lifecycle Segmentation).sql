/*
==================================================================================
Ticket 13: Customer Lifecycle Segmentation (Business RFM)
==================================================================================
*/

WITH Customer_summary AS 
(SELECT c.customer_id,
 MAX(o.order_date) AS last_order_date, 
 DATEDIFF((SELECT MAX(order_date) FROM orders),
 MAX(o.order_date)) AS recency_days, 
 COUNT(o.order_id) AS total_orders, 
 SUM(o.order_amount) AS total_revenue, 
 ROUND(AVG(o.order_amount),2) AS average_order_value 
 FROM customers c 
 LEFT JOIN orders o 
 ON c.customer_id = o.customer_id 
 GROUP BY c.customer_id),  
 
 RFM AS 
 (SELECT *, 
 CASE 
 WHEN recency_days <= 30 THEN 'Active'
 WHEN recency_days <= 90 THEN 'Warm' 
 WHEN recency_days <= 180 THEN 'Needs Attention' 
 WHEN recency_days <= 365 THEN 'At Risk' 
 ELSE 'Lost' 
 END AS recency_segment, 
 
 CASE 
 WHEN total_orders >= 8 THEN 'High' 
 WHEN total_orders >= 4 THEN 'Medium' 
 ELSE 'Low'
 END AS frequency_segment, 
 
 CASE 
 WHEN total_revenue >= 8000 THEN 'High' 
 WHEN total_revenue >= 3000 THEN 'Medium' 
 ELSE 'Low' 
 END AS monetary_segment 
 
 FROM Customer_summary),  
 
 Customer_segment AS 
 (SELECT *, 
 CASE WHEN recency_segment='Active'
 AND frequency_segment='High' 
 AND monetary_segment='High' 
 THEN 'Champions' 
 
 WHEN recency_segment='Active' 
 AND monetary_segment='High' 
 THEN 'Big Spenders'  
 
 WHEN recency_segment IN ('Warm','Needs Attention') 
 AND frequency_segment IN ('High','Medium') 
 AND monetary_segment IN ('High','Medium') 
 THEN 'Loyal Customers'  
 
 WHEN recency_segment='Active' 
 AND frequency_segment='Low' 
 AND monetary_segment='Low' 
 THEN 'New Customers'  
 
 WHEN recency_segment='At Risk' 
 AND monetary_segment='High' THEN 'Win Back'  
 WHEN recency_segment='Lost' THEN 'Lost Customers'  
 ELSE 'Low Value Customers' 
 END AS customer_segment  
 FROM RFM),
 
 Executive_summary AS 
 (SELECT customer_segment, 
 COUNT(customer_id) AS Customer_count, 
 SUM(total_orders) AS total_orders, 
 ROUND(100*SUM(total_orders)/SUM(SUM(total_orders)) OVER(),2) AS order_pct, 
 ROUND(SUM(total_revenue),2) AS revenue, 
 ROUND(100*SUM(total_revenue)/SUM(SUM(total_revenue)) OVER(),2) AS revenue_pct, 
 ROUND(SUM(total_revenue)/SUM(total_orders),2) AS average_order_value 
 FROM Customer_segment 
 GROUP BY customer_segment
 ORDER BY COUNT(customer_id) desc,
 SUM(total_orders) desc,
 ROUND(SUM(total_revenue),2) desc)  
 
 SELECT * FROM Executive_summary;



/*=========================================================
Executive Findings
===========================================================

1. Customer Lifecycle Segmentation classified customers into seven actionable business segments based on recency, purchase frequency and monetary value.

2. Although Low Value Customers account for the largest customer base, they contribute only about 37% of total revenue, indicating relatively low spending per customer.

3. Loyal Customers contribute nearly 32% of total revenue while representing a much smaller share of customers, making them an attractive target for retention and upselling initiatives.

4. Champions represent a very small proportion of customers but generate disproportionately high revenue, highlighting the importance of premium retention strategies.

5. Win Back and Big Spenders represent high-value but limited customer groups that should receive personalized campaigns to maximize future revenue.

===========================================================
Executive Recommendations
===========================================================

1. Protect Champions through loyalty programs, exclusive rewards and priority customer support.

2. Increase purchase frequency of Big Spenders using personalized offers and product recommendations.

3. Retain Loyal Customers through targeted engagement campaigns before they transition into At Risk segments.

4. Design automated onboarding campaigns for New Customers to encourage repeat purchases.

5. Use low-cost promotional campaigns for Low Value Customers while avoiding excessive discounting.

6. Launch win-back campaigns for high-value At Risk customers before they become permanently inactive.

7. Allocate marketing budgets based on customer value rather than applying identical campaigns across the entire customer base.
