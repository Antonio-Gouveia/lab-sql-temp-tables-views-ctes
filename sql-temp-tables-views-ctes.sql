-- Step 1: Create a View (Visão)customer_list
USE sakila;

CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
    customer AS c
JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email;

-- SELECT * FROM customer_rental_summary LIMIT 10;
SELECT
    customer_id,
    customer_name,
    rental_count,
    email
FROM
    customer_rental_summary
LIMIT 10; 

-- Step 2: Create a Temporary Table
-- Calculates the total amount paid by each customer (total_paid).
-- We join the previously created View (customer_rental_summary) with the payment table.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM
    customer_rental_summary AS crs
JOIN
    payment AS p ON crs.customer_id = p.customer_id
GROUP BY
    crs.customer_id;
    
-- Step 3: Create a CTE and the Customer Summary Report

WITH customer_summary_cte AS (
    -- The CTE joins the View (customer_rental_summary) with the Temporary Table (customer_payment_summary).
    SELECT
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM
        customer_rental_summary AS crs
    JOIN
        customer_payment_summary AS cps ON crs.customer_id = cps.customer_id
)
-- Final Query: Generates the Customer Summary Report using the CTE.
SELECT
    csc.customer_name,
    csc.email,
    csc.rental_count,
    csc.total_paid,
    -- Calculates the derived column: average_payment_per_rental (total_paid / rental_count)
    (csc.total_paid / csc.rental_count) AS average_payment_per_rental
FROM
    customer_summary_cte AS csc
ORDER BY
    csc.customer_name;