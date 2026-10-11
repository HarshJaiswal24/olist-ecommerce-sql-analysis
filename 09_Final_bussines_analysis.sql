-- Question1: How many repeat customers are there?

SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_customer_list;

-- Question2: what percentage of customers are repeat customers?

WITH customer_orders AS (
    SELECT customer_id, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),2) AS repeat_customer_percentage
FROM customer_orders;

-- Question3: Average number of orders per customer

SELECT
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM (
    SELECT customer_id, COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
) AS customer_orders;

-- Question4: Top 10 Customers by Spending

SELECT o.customer_id, ROUND(SUM(oi.price), 2) AS total_spent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;
 
-- Question5: Top 10 product categories by number of items sold

SELECT ct.product_category_name_english AS category, COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 10;

-- Question 6 — Top 10 categories by average product price

SELECT ct.product_category_name_english AS category, ROUND(AVG(oi.price), 2) AS average_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(*) >= 50
ORDER BY average_price DESC
LIMIT 10;

-- Question 7: Which categories generate the most freight cost?


 SELECT ct.product_category_name_english AS category, ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_freight DESC
LIMIT 10;

-- Question 8: Top 10 sellers by revenue

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS avg_item_price
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Question 9: Sellers with high revenue but low order volume

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) <= 20
ORDER BY total_revenue DESC
LIMIT 10;

-- Question 10: What percentage of orders were delivered late?

SELECT
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- Question 11: Which states have the most late deliveries?

SELECT c.customer_state, COUNT(*) AS late_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date >
      o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY late_orders DESC;


-- Question 12: Average delivery delay by state?

SELECT
    c.customer_state,
    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_estimated_delivery_date
            )
        ),
        2
    ) AS avg_delay_days
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date >
      o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;

-- Question 13: Review score by product category

SELECT ct.product_category_name_english AS category, ROUND(AVG(r.review_score), 2) AS average_review_score, COUNT(*) AS total_reviews
FROM order_reviews r
JOIN order_items oi
    ON r.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(*) >= 50
ORDER BY average_review_score DESC;

-- Question 14: Most popular payment methods

SELECT payment_type, COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_type
ORDER BY total_payments DESC;

-- Question 15: Revenue by payment method

SELECT payment_type, ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- Question 16: Average installments by payment type

SELECT payment_type, ROUND(AVG(payment_installments), 2) AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY avg_installments DESC;

-- Question 17: Rank categories by revenue

WITH category_revenue AS (
    SELECT
        ct.product_category_name_english AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY revenue DESC
    ) AS category_rank
FROM category_revenue
ORDER BY category_rank;

-- Question 18: Top 3 categories by revenue

WITH category_revenue AS (
    SELECT
        ct.product_category_name_english AS category,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY ct.product_category_name_english
),

ranked_categories AS (
    SELECT
        category,
        revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS category_rank
    FROM category_revenue
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    category_rank
FROM ranked_categories
WHERE category_rank <= 3;

-- Question 18: Top products within each category

WITH product_sales AS (
    SELECT p.product_id, ct.product_category_name_english AS category, SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY
        p.product_id,
        ct.product_category_name_english
),

ranked_products AS (
    SELECT
        product_id,
        category,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_sales
)

SELECT product_id, category, ROUND(revenue, 2) AS revenue, product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;

