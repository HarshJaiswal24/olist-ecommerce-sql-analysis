-- Question1: Total Product sales

SELECT SUM(price) AS total_sales
FROM order_items;

-- Question2: Average Product Price

SELECT AVG(price) AS average_price
FROM order_items;

-- Question3: Highest and Lowest Product Price

SELECT MAX(price) AS highest_price, MIN(price) AS lowest_price
FROM order_items;

-- Question4: sales by seller

SELECT seller_id, SUM(price) AS total_sales
FROM order_items
GROUP BY seller_id
ORDER BY total_sales DESC;

-- Question5: Top 10 sellers

SELECT seller_id, SUM(price) AS total_sales
FROM order_items
GROUP BY seller_id
ORDER BY total_sales DESC
LIMIT 10;