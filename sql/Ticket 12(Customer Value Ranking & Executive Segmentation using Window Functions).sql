/*
==================================================================================
Ticket 12: Customer Value Ranking & Executive Segmentation using Window Functions
==================================================================================

Business Question:
How can FoodRush identify and rank its most valuable customers, measure each segment's contribution to revenue, and support targeted marketing decisions?
Business Context:

Business Context:
FoodRush wants to optimize its marketing budget by identifying high-value customer segments, understanding their revenue contribution, and prioritizing retention and growth strategies.

SQL Concepts Used:
- CTEs
- DENSE_RANK()
- NTILE(),
- Window Functions
- Aggregate Functions (SUM, COUNT, AVG)
- Window Aggregation (SUM(SUM()) OVER())
- CASE
====================================================
*/

WITH customer AS
(SELECT
c.customer_id,
SUM(o.order_amount) AS Total_revenue,
COUNT(o.order_id) AS Total_orders
FROM Customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id),

customer_rank AS
(SELECT *, 
DENSE_RANK()OVER(ORDER BY total_revenue desc) as customer_rank
FROM customer),

Customer_Segment AS
(SELECT *,
CASE
NTILE(5)OVER(ORDER BY Total_revenue desc)
WHEN 1 THEN 'Diamond'
WHEN 2 THEN 'Platinum'
WHEN 3 THEN 'Gold'
WHEN 4 THEN 'Silver'
WHEN 5 THEN 'Bronze'
END AS Customer_Segments
FROM customer_rank),

segment_statistics AS
(SELECT customer_segments,
COUNT(customer_id) AS Customer_count,
ROUND(AVG(Total_orders),2) AS AVG_orders,	
ROUND((SUM(Total_revenue)/COUNT(Total_orders)),2) AS AOV
FROM Customer_Segment
GROUP BY customer_segments),

Executive_summary AS
(SELECT 
Customer_segments,
Round(100 * COUNT(customer_id)/SUM(COUNT(customer_id)) OVER(),2) AS Cust_percentage,
ROUND(100 * SUM(Total_orders)/SUM(SUM(Total_orders)) OVER(),2) AS order_percentage,
ROUND(100 * SUM(Total_revenue)/SUM(SUM(Total_revenue)) OVER(),2) AS Revenue_percentage,
FROM 
Customer_Segment
GROUP BY Customer_segments)

SELECT * FROM Executive_summary;


/*=========================================================
Executive Findings
===========================================================

1. Customer segmentation was performed using NTILE(5), dividing customers into five equally sized groups based on total revenue.

2. Although each segment contains approximately 20% of customers, revenue distribution is highly uneven.

3. The Diamond segment contributes approximately 53% of total revenue and 52% of total orders, indicating that a relatively small group of high-value customers generates the majority of business.

4. Platinum customers contribute over 21% of revenue, making them the second most valuable customer segment and a strong opportunity for revenue growth.

5. Bronze customers contribute only around 4% of revenue despite generating more than 7% of total orders, suggesting significantly lower average order values compared to higher-value segments.

=========================================================
Executive Recommendations
===========================================================

1. Prioritize retention of Diamond customers through loyalty programs, premium support, and personalized experiences, as losing these customers would have a disproportionate impact on revenue.

2. Target Platinum customers with upselling and cross-selling campaigns to increase their lifetime value and move more customers into the Diamond segment.

3. Design differentiated marketing campaigns for Gold customers to encourage higher spending and increase purchase frequency.

4. Review the profitability of Bronze customers before allocating significant marketing budgets, as their revenue contribution is relatively low compared to their order volume.

5. Avoid blanket discount campaigns across all customer segments. Instead, allocate marketing spend based on customer value and expected return on investment.


