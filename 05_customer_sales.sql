-- Question1: Which state generate  the most sales

SELECT c.customer_state, SUM(oi.price) AS total_sales
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;

-- Question2: Seller who generated more than 10,000 sales

SELECT seller_id, SUM(price) AS total_sales
FROM order_items
GROUP BY seller_id
HAVING SUM(price) > 10000
ORDER BY total_sales DESC;

