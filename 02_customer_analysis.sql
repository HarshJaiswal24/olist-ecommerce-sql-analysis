-- Question1: How many customers are there?

SELECT COUNT(*) AS total_customers
FROM customers;

-- Question2: How many customers by state?

SELECT
    customer_state, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Question3: Top 10 customer cities\

SELECT customer_city, COUNT(*) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;