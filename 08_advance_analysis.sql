-- Question1: Find Seller rank

WITH seller_sales AS (
    SELECT seller_id, SUM(price) AS total_sales
    FROM order_items
    GROUP BY seller_id
)

SELECT seller_id, total_sales,
    DENSE_RANK() OVER (
        ORDER BY total_sales DESC
    ) AS seller_rank
FROM seller_sales;

-- Question2:  Monthly Revenue comparing to previous month revenue

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
)

SELECT
    month, 
    revenue,
    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue
FROM monthly_sales
ORDER BY month;

-- Question3: Running total of Revenue

 WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
)

SELECT
    month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY month
    ) AS running_revenue
FROM monthly_sales
ORDER BY month;

-- Question4: Customer repeat analysis

SELECT customer_id, COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;