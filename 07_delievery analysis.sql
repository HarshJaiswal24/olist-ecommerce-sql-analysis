-- Question1: Find late orders

SELECT order_id, order_delivered_customer_date, order_estimated_delivery_date
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;
      
-- Question2: calculate delivery delay

SELECT order_id,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days
FROM orders
WHERE order_delivered_customer_date >  order_estimated_delivery_date;

-- Question3: Average Delivery Time

SELECT
    AVG(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp)
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Question 4: Does late delivery effect reviews

SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    AVG(r.review_score) AS average_review_score
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END;