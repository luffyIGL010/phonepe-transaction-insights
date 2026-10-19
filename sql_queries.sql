-- Q1: Top 10 states by total amount
SELECT state,
       SUM(txn_count) AS total_txns,
       ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore
FROM map_transaction
GROUP BY state
ORDER BY amount_crore DESC
LIMIT 10;

-- Q2: Saal-dar-saal growth (poore India ka)
WITH yearly AS (
    SELECT year, SUM(txn_count) AS txns, SUM(txn_amount)::numeric AS amt
    FROM map_transaction
    WHERE year < 2026
    GROUP BY year
)
SELECT year, txns,
       ROUND(amt / 1e7, 2) AS amount_crore,
       ROUND(100.0 * (amt - LAG(amt) OVER (ORDER BY year))
             / NULLIF(LAG(amt) OVER (ORDER BY year), 0), 1) AS yoy_pct
FROM yearly
ORDER BY year

-- Q3: Quarter-wise trend (seasonality)
WITH q AS (
    SELECT year, quarter, SUM(txn_count)::numeric AS txns
    FROM map_transaction
    WHERE year BETWEEN 2022 AND 2025
    GROUP BY year, quarter
),
g AS (
    SELECT year, quarter, txns,
           LAG(txns) OVER (ORDER BY year, quarter) AS prev
    FROM q
)
SELECT quarter,
       ROUND(AVG(100.0 * (txns - prev) / prev), 1) AS avg_qoq_growth_pct
FROM g
WHERE prev IS NOT NULL
GROUP BY quarter
ORDER BY quarter;

-- Q4: Transaction type share
SELECT year, txn_type,
       ROUND(100.0 * SUM(txn_count) / SUM(SUM(txn_count)) OVER (PARTITION BY year), 1) AS share_pct
FROM agg_transaction
WHERE year < 2026
GROUP BY year, txn_type
ORDER BY year, txn_type;

-- Q5: Top 10 districts
SELECT state, district,
       SUM(txn_count) AS total_txns,
       ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore
FROM map_transaction
GROUP BY state, district
ORDER BY total_txns DESC
LIMIT 10;

-- Q6: Transactions per registered user (2025)
WITH t AS (
    SELECT state, SUM(txn_count) AS txns
    FROM agg_transaction
    WHERE year = 2025
    GROUP BY state
),
u AS (
    SELECT state, MAX(registered_users) AS users
    FROM agg_user
    WHERE year = 2025
    GROUP BY state
)
SELECT t.state, t.txns, u.users,
       ROUND(t.txns::numeric / u.users, 1) AS txns_per_user
FROM t JOIN u USING (state)
ORDER BY txns_per_user DESC;

-- Q7: Har state ke top 3 districts
SELECT * FROM (
    SELECT state, district,
           ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore,
           RANK() OVER (PARTITION BY state ORDER BY SUM(txn_amount) DESC) AS rnk
    FROM map_transaction
    GROUP BY state, district
) x
WHERE rnk <= 3
ORDER BY state, rnk;

-- Q8: Top states ka share (concentration)
WITH s AS (
    SELECT state, SUM(txn_amount)::numeric AS amt
    FROM map_transaction
    GROUP BY state
)
SELECT state,
       ROUND(100.0 * amt / SUM(amt) OVER (), 2) AS share_pct,
       ROUND(100.0 * SUM(amt) OVER (ORDER BY amt DESC) / SUM(amt) OVER (), 1) AS cumulative_pct
FROM s
ORDER BY amt DESC
LIMIT 10;


-- Validation: dono tables ka total count match karta hai ya nahi
SELECT (SELECT SUM(txn_count) FROM agg_transaction) AS agg_total,
       (SELECT SUM(txn_count) FROM map_transaction) AS map_total;