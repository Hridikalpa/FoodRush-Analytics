# FoodRush Analysis Summary

## 1. Executive Performance

The overview establishes the baseline business metrics and exposes the main dimensions used to investigate performance: time, city, cuisine and order status.

## 2. Customer Behaviour

Order activity is decomposed into two drivers:

- number of ordering customers
- orders per ordering customer

This avoids interpreting a change in total orders as a single phenomenon.

## 3. Restaurant Intelligence

Restaurant analysis combines commercial and customer-experience metrics:

- revenue
- order volume
- AOV
- rating
- cancellation rate

The goal is exception identification rather than ranking alone.

## 4. Operations

Operational investigation focuses on:

- delivered vs cancelled orders
- cancellation rate by order city
- average delivery time by order city
- delivery cost
- restaurant-level cancellation and delivery performance

## Example investigation path

```text
Overall cancellation rate
        ↓
City exception
        ↓
Restaurant exception
        ↓
Inspect delivery-time / volume context
        ↓
Form a testable hypothesis
```

## Analytical caution

A high cancellation rate and a high delivery time occurring together are evidence of a pattern worth investigating. They are not, by themselves, proof of causality.
