--1. What is the total number of orders, total revenue, and average order value?
  SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price)::numeric, 2) AS total_revenue,
    ROUND(
        (SUM(price) / COUNT(DISTINCT order_id))::numeric,
        2
    ) AS average_order_value
FROM order_items;

--2. How does monthly revenue change over time?
    SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price)::numeric, 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY 1
    ORDER BY 1;

--3. Which product categories generate the highest revenue?
    SELECT
    p.product_category_name,
    ROUND(SUM(oi.price)::numeric, 2) AS revenue
    FROM order_items oi
    JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
    ORDER BY revenue DESC
    LIMIT 10;
--4. What is the distribution of orders across different order statuses?
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ())::numeric,
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

--5. What percentage of customers are repeat customers?
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        (
            COUNT(*) FILTER (WHERE order_count > 1) * 100.0
            / COUNT(*)
        )::numeric,
        2
    ) AS repeat_customer_percentage
FROM customer_orders;

--8. Which payment methods are most frequently used by customers?
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ())::numeric,
        2
    ) AS percentage
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;