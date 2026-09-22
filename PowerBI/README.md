# FoodRush Power BI Report

Open `FoodRush.pbix` with **Power BI Desktop**.

## Report pages

### Overview
Executive KPI baseline, revenue trend, cuisine contribution, order outcomes and city performance.

### Customer Intelligence
Ordering customers, order frequency and city-level customer behaviour.

### Restaurant Intelligence
Revenue, cancellation risk, rating comparison and restaurant-level investigation.

### Operations Intelligence
Order-city cancellation, delivery time, delivery cost and restaurant operational detail.

## Core DAX measures

- `Total Revenue`
- `Total Orders`
- `Ordering Customers`
- `AOV`
- `Delivered Orders`
- `Cancelled Orders`
- `Cancellation Rate`
- `Orders per Customer`
- `Average Delivery Time`
- `Average Delivery Cost`

The report uses a dedicated `_measures` table for DAX measures and a dimensional relationship structure connecting customers and restaurants to orders, with customer sessions as a separate fact table.
