-- =========================
-- CUSTOMERS
-- Grain: 1 row = 1 customer
-- =========================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE,
    city VARCHAR(50),
    acquisition_channel VARCHAR(50),
    gender VARCHAR(10),
    age INT
);

-- =========================
-- RESTAURANTS
-- Grain: 1 row = 1 restaurant
-- =========================

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    cuisine VARCHAR(50),
    city VARCHAR(50),
    rating DECIMAL(2,1)
);

-- =========================
-- ORDERS
-- Grain: 1 row = 1 order
-- =========================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    city VARCHAR(50),
    order_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    payment_mode VARCHAR(20),
    order_status VARCHAR(20),
    delivery_time_min INT,
    food_cost DECIMAL(10,2),
    delivery_cost DECIMAL(10,2)
);

-- =========================
-- WEBSITE SESSIONS
-- Grain: 1 row = 1 session
-- =========================

CREATE TABLE website_sessions (
    session_id INT PRIMARY KEY,
    customer_id INT,
    session_date DATE,
    traffic_source VARCHAR(50),
    device VARCHAR(20),
    converted BOOLEAN
);
