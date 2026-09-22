# FoodRush Interview Story

## 60-second version

"FoodRush is an end-to-end food-delivery analytics case study. I started by validating and profiling the source data, then used SQL to answer business questions around revenue, customer retention, churn, customer value and restaurant performance. In Power BI I built a dimensional model and reusable DAX measures, then organised the report into four views: executive performance, customer intelligence, restaurant intelligence and operations. The main analytical approach was to move from a KPI to its drivers and then drill into exceptions. For example, rather than stopping at an elevated cancellation rate in one city, I drilled into restaurant-level cancellation and delivery-time metrics to identify investigation candidates. The project demonstrates the full workflow from data quality through SQL, modelling, DAX and business reporting." 

## 3-minute structure

1. **Business problem** — understand performance, customers, restaurants and operations.
2. **Data** — customers, restaurants, orders and website sessions.
3. **Quality** — profile missing values, duplicates, invalid keys, numeric/date problems and business-rule exceptions.
4. **SQL** — CTEs, joins, conditional aggregation, date analysis and advanced window functions.
5. **Model** — customer and restaurant dimensions feeding the orders fact; sessions as a separate fact.
6. **DAX** — reusable KPIs and filtered measures with `CALCULATE()`.
7. **Dashboard** — four purpose-driven pages rather than one overloaded report.
8. **Business reasoning** — identify drivers and exceptions; distinguish evidence from hypotheses.

## Common interviewer follow-ups

### Why use a measure for AOV?
AOV needs to respond to the current filter context, so it is defined from reusable revenue and order measures rather than a fixed pre-aggregated number.

### Why `DISTINCTCOUNT` for Ordering Customers?
The same customer can appear in multiple order rows, so the KPI counts unique customers in the orders fact table.

### Why `CALCULATE()` for Delivered Orders?
It evaluates the existing Total Orders measure under a changed filter context where order status is Delivered.

### Why separate Customers and Restaurants from Orders?
Customers and restaurants describe business entities; Orders records transactions. Keeping them separate supports consistent slicing of the fact table and avoids duplicating descriptive attributes.

### How do you interpret a high cancellation rate?
Treat it as an exception signal. First compare it with the overall baseline, then drill into volume and lower-level entities. Avoid claiming a causal explanation without supporting evidence.
