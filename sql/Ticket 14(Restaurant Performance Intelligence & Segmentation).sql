/*
==================================================================================
Ticket 12: Customer Value Ranking & Executive Segmentation using Window Functions
==================================================================================

Business Question:
FoodRush partners with hundreds of restaurants, but not all contribute equally to business growth. Management needs a framework to identify high-performing restaurants, detect operational risks, and uncover growth opportunities.
This analysis develops a restaurant intelligence model using revenue, order volume, customer ratings, and cancellation rates to classify restaurants into actionable business segments.

Dataset
Tables Used:
-Restaurants
-Orders

SQL Concepts Used:
-Common Table Expressions (CTEs)
-LEFT JOIN
-Aggregate Functions
-CASE Expressions
-Window Functions (DENSE_RANK())
-Conditional Aggregation
-Business Segmentation
-Multi-stage Analytical Pipeline





Restaurant Segments
Segment	Business Meaning
-Star Partner	High revenue: high order volume, excellent customer ratings, and healthy operations. These restaurants should receive premium visibility and strategic partnerships.
-Operational Risk :	Strong revenue generators with elevated cancellation rates, indicating operational inefficiencies requiring investigation.
-Hidden Gem	: Excellent customer ratings but comparatively lower commercial performance. These restaurants are strong candidates for promotional campaigns.
-Growth Opportunity	: High customer demand but lower revenue generation, suggesting opportunities to improve average order value through upselling and bundled offers.
-Needs Quality Improvement: Strong commercial performance but weaker customer ratings. These restaurants require quality improvement initiatives.
-Standard Performer : Restaurants operating within expected performance levels without major strengths or weaknesses.
====================================================
*/

WITH restaurant_summary AS
(SELECT 
r.restaurant_id,
r.restaurant_name,
r.cuisine,
r.city,
COUNT(o.order_id) AS Total_orders,
SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND(SUM(order_amount),2) AS Total_revenue,
ROUND(AVG(order_amount),2) AS AOV,
AVG(r.rating) AS Avg_rating,
ROUND(100 *SUM(CASE WHEN o.order_status='Cancelled' THEN 1 ELSE 0 END)/NULLIF(COUNT(order_id),0),2) AS cancellation_rate
FROM
restaurants r
LEFT JOIN Orders o
ON r.restaurant_id=o.restaurant_id
GROUP BY r.restaurant_id,
r.restaurant_name,
r.cuisine,
r.city),

restaurant_rank AS
(SELECT 	
*,
DENSE_RANK()OVER(ORDER BY Total_revenue DESC) AS Revenue_rank,
DENSE_RANK()OVER(ORDER BY Total_orders DESC) AS order_rank,
DENSE_RANK()OVER(ORDER BY Avg_rating DESC) AS Rating_rank,
DENSE_RANK()OVER(ORDER BY cancellation_rate DESC) AS cancellation_rank
FROM restaurant_summary),

rank_distribution AS
(SELECT 'Revenue' AS metric, revenue_rank AS rank_value FROM restaurant_rank
UNION ALL
SELECT 'order', order_rank FROM restaurant_rank
UNION ALL
SELECT 'Rating', rating_rank FROM restaurant_rank
UNION ALL
SELECT 'cancellation', cancellation_rank FROM restaurant_rank),

rank_summary AS
(SELECT 
metric,
rank_value,
COUNT(*) AS restaurants
FROM rank_distribution
GROUP BY metric, rank_value
),

cumulative_rank_Percentage AS
(SELECT
*,
SUM(restaurants)OVER(PARTITION BY metric ORDER BY rank_value) AS cum_restaurant_rank,
ROUND(SUM(restaurants)OVER(PARTITION BY metric ORDER BY rank_value)*100/(SUM(restaurants) OVER(PARTITION BY metric)),2) AS cum_restaurant_rank_perc
FROM rank_summary),

restaurant_intelligence AS
(
SELECT *,
CASE
WHEN revenue_rank <= 15 THEN 'Top Revenue'
ELSE 'Normal Revenue'
END AS revenue_flag,

CASE
WHEN order_rank <= 6 THEN 'High Orders'
ELSE 'Normal Orders'
END AS order_flag,

CASE
WHEN rating_rank <= 3 THEN 'Top Rated'
ELSE 'Normal Rating'
END AS rating_flag,

CASE
WHEN cancellation_rank <= 15 THEN 'High Cancellation'
ELSE 'Healthy Cancellation'
END AS cancellation_flag

FROM restaurant_rank
),

restaurant_segment AS
(
SELECT
*,

CASE

WHEN revenue_flag='Top Revenue'
AND order_flag='High Orders'
AND rating_flag='Top Rated'
AND cancellation_flag='Healthy Cancellation'
THEN 'Star Partner'

WHEN revenue_flag='Top Revenue'
AND cancellation_flag='High Cancellation'
THEN 'Operational Risk'

WHEN rating_flag='Top Rated'
AND revenue_flag='Normal Revenue'
THEN 'Hidden Gem'

WHEN order_flag='High Orders'
AND revenue_flag='Normal Revenue'
THEN 'Growth Opportunity'

WHEN revenue_flag='Top Revenue'
AND rating_flag='Normal Rating'
THEN 'Needs Quality Improvement'

ELSE 'Standard Performer'

END AS restaurant_segment
FROM restaurant_intelligence
),
executive_summary AS
(SELECT
restaurant_segment,
COUNT(*) AS total_restaurants,
SUM(total_orders) AS total_orders,
ROUND(SUM(total_revenue),2) AS total_revenue,
ROUND(AVG(avg_rating),2) AS avg_rating,
ROUND(AVG(cancellation_rate),2) AS avg_cancellation_rate,
ROUND(AVG(AOV),2) AS avg_order_value
FROM restaurant_segment
GROUP BY restaurant_segment)

SELECT * FROM executive_summary

/*=========================================================
Key Findings
===========================================================

1. Majority of restaurants are Standard Performers.
73% of restaurants fall into the Standard Performer category, contributing the majority of platform revenue while maintaining average operational performance.

2. Star Partners represent the benchmark for platform excellence.
Only two restaurants qualified as Star Partners by simultaneously achieving high revenue, high order volume, excellent customer ratings, and acceptable cancellation performance.
These restaurants should be prioritized for exclusive promotions, premium placement, and long-term partnerships.

3. Operational Risks require immediate attention.
Three restaurants generate strong revenue despite recording the highest cancellation rates.
Reducing cancellations for these restaurants could improve customer satisfaction while protecting existing revenue.

4. Hidden Gems are underutilized assets.Seven restaurants maintain outstanding customer ratings (average 4.87) but have relatively lower commercial performance.
Increasing their visibility through recommendations or marketing campaigns could generate additional revenue with minimal operational investment.

5. Growth Opportunity restaurants demonstrate healthy customer demand.Six restaurants receive substantial order volumes but generate comparatively lower revenue.
Strategies such as combo offers, upselling, and menu optimization could improve average order value.

6. Quality Improvement should focus on commercially important restaurants.Nine restaurants produce strong revenue but maintain relatively weaker customer ratings.
Operational coaching, food quality improvements, and service monitoring could increase customer satisfaction while preserving revenue.

=========================================================
Recommendations
===========================================================

Recommendation 1 — Expand strategic partnerships.Increase visibility and promotional support for Star Partners through featured listings, loyalty campaigns, and premium placement.

Recommendation 2 — Reduce operational failures.Investigate Operational Risk restaurants to identify causes of elevated cancellations, such as stock shortages, delivery delays, or kitchen capacity issues.

Recommendation 3 — Promote Hidden Gems.Launch targeted marketing campaigns to improve the visibility of highly rated restaurants with untapped commercial potential.

Recommendation 4 — Increase Average Order Value.Introduce bundled meals, add-on recommendations, and personalized promotions for Growth Opportunity restaurants.

Recommendation 5 — Improve Customer Experience.Provide operational coaching and quality monitoring for restaurants identified under Needs Quality Improvement.
