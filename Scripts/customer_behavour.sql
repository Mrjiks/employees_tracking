/* 1. Comparing Purchase Amounts:
   This query compares a customer's current purchase amount with their previous purchase amount to identify trends over time. */
SELECT user_id, date, purchase_amount,
       purchase_amount - LAG(purchase_amount) OVER (PARTITION BY user_id ORDER BY date) as amount_difference
FROM public.customer_seg;

/* 2. Customer Retention Rate:
   This query calculates the retention rate by acquisition month, helping businesses understand customer loyalty and seasonal trends. */
WITH customer_data AS (
SELECT user_id, purchased, date,
EXTRACT(MONTH FROM date) as acquisition_month
FROM public.customer_seg)
SELECT acquisition_month, COUNT(DISTINCT user_id) as cohort_size,
COUNT(DISTINCT CASE WHEN purchased = 1 THEN user_id END) as retained_customers,
FLOOR((COUNT(DISTINCT CASE WHEN purchased = 1 THEN user_id END) / COUNT(DISTINCT user_id)::float) * 100) || '%' as retention_rate
FROM customer_data
GROUP BY acquisition_month
ORDER BY acquisition_month;

/* 3. Age Bracket Purchases:
   This query identifies which age groups have the highest and lowest total purchases to target marketing efforts effectively. */
WITH customer_data AS (SELECT user_id, 
           CASE
                WHEN age BETWEEN 0 and 18 THEN '0-18'
                WHEN age BETWEEN 19 and 25 THEN '19-25'
                WHEN age BETWEEN 26 and 35 THEN '26-35'
                WHEN age BETWEEN 36 and 45 THEN '36-45'
                WHEN age BETWEEN 46 and 55 THEN '46-55'
                WHEN age > 55 THEN '56+'
           END as age_group, purchased
    FROM public.customer_seg
    WHERE purchased = 1)
SELECT age_group, SUM(purchased) as total_purchases, 'max' as type
FROM customer_data
GROUP BY age_group
HAVING SUM(purchased) = (SELECT MAX(total_purchases) FROM 
(SELECT age_group, SUM(purchased) as total_purchases FROM customer_data 
 GROUP BY age_group) as max_purch)
UNION
SELECT age_group, SUM(purchased) as total_purchases, 'min' as type
FROM customer_data
GROUP BY age_group
HAVING SUM(purchased) = (SELECT MIN(total_purchases) FROM 
(SELECT age_group, SUM(purchased) as total_purchases FROM customer_data 
GROUP BY age_group) as min_purch)
ORDER BY total_purchases DESC;

/* 4. Average Purchase Value by Cohort (2021):
   This query analyzes the average purchase value by cohort month in 2021 to understand changes in customer behavior over time. */
WITH customer_cohort AS (SELECT
DATE_TRUNC('month', date) as cohort_month,user_id,
SUM(purchase_amount) as total_purchase_amount
FROM public.customer_seg WHERE date >= '2021-01-01' AND date < '2022-01-01'
GROUP BY cohort_month, user_id)
SELECT
cohort_month,
EXTRACT(MONTH FROM cohort_month) as cohort_month_only,
FLOOR (AVG(total_purchase_amount)) AS Average_purchase
FROM customer_cohort
GROUP BY cohort_month order by cohort_month_only asc;

/* 5. Comparing Average Purchase Values (2021 vs. 2022):
   This query compares the average purchase values between 2021 and 2022 to detect trends and make strategic adjustments. */
WITH customer_cohort AS (SELECT
DATE_TRUNC('month', date) as cohort_month,
EXTRACT(YEAR FROM DATE_TRUNC('month', date)) as cohort_year,
user_id,
SUM(purchase_amount) as total_purchase_amount
FROM public.customer_seg
GROUP BY cohort_month, user_id)
SELECT
cohort_year,
FLOOR (AVG(total_purchase_amount)) AS Average_purchase
FROM customer_cohort
WHERE cohort_year IN (2021,2022)
GROUP BY cohort_year
ORDER BY cohort_year;

/* 6. Comparing Average Purchase Values Over Time (2021 vs. 2022):
   This query compares average purchase values by month between 2021 and 2022 to identify trends and adjust marketing strategies. */
WITH customer_cohort_2021 AS (SELECT
DATE_TRUNC('month', date) as cohort_month, user_id,
SUM(purchase_amount) as total_purchase_amount
FROM public.customer_seg
WHERE date >= '2021-01-01' AND date < '2022-01-01'
GROUP BY cohort_month, user_id),
customer_cohort_2022 AS (SELECT
DATE_TRUNC('month', date) as cohort_month,user_id,
SUM(purchase_amount) as total_purchase_amount
FROM public.customer_seg
WHERE date >= '2022-01-01' AND date < '2023-01-01'
GROUP BY cohort_month, user_id) SELECT cohort_month,
FLOOR (AVG(total_purchase_amount)) AS avg_purchase_2021,
FLOOR (AVG(total_purchase_amount)) AS avg_purchase_2022
FROM customer_cohort_2021
GROUP BY cohort_month
UNION
SELECT cohort_month,
NULL as avg_purchase_2021,
FLOOR (AVG(total_purchase_amount)) AS avg_purchase_2022
FROM customer_cohort_2022
GROUP BY cohort_month;

/* 7. Average Purchase Value Over Time (2019):
   This query calculates the average purchase value for 2019 and 2021 to compare changes in customer spending behavior. */
WITH customer_cohort AS (
SELECT
DATE_TRUNC('month', date) as cohort_month,
user_id,
SUM(purchase_amount) as total_purchase_amount
FROM public.customer_seg
WHERE date_part('year', date) IN (2019, 2021)
GROUP BY cohort_month, user_id)
SELECT
cohort_month,
DATE_PART('year', cohort_month) as year,
FLOOR (AVG(total_purchase_amount)) as average_purchase
FROM customer_cohort
GROUP BY cohort_month, year
ORDER BY cohort_month, year;

/* 8. High Earners Check:
   This query checks if there are any customers with a salary exceeding 150,000. */
SELECT EXISTS (SELECT FROM public.customer_seg WHERE salary > 150000);

/* Data Addition Example:
   Inserts a new record into the `customer_seg` table and retrieves a specific record for verification. */
INSERT INTO public.customer_seg VALUES (425, 'Female', 20, 36000, 1, current_date-32, 1070);
SELECT * FROM public.customer_seg WHERE user_id = 5;
