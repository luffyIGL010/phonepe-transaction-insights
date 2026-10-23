-- PhonePe Pulse analysis | Data: 2018 Q1 to 2026 Q2 (2026 is incomplete)
-- Q2, Q3, Q4b use 2018-2025 only; Q1, Q4a, Q5, Q7, Q8, Q9, Q10 include 2026 H1


-- Q1: Top 10 states by total amount (2018 to Q2 2026)
SELECT state,
       SUM(txn_count) AS total_txns,
       ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore
FROM map_transaction
GROUP BY state
ORDER BY amount_crore DESC
LIMIT 10;


-- Q2: Year-over-year growth, all India (2018-2025)
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
ORDER BY year;


-- Q3: Avg quarter-on-quarter growth, 2023-2025 (seasonality check)
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

WHERE prev IS NOT NULL AND year >= 2023
GROUP BY quarter
ORDER BY quarter;


-- Q4a: Overall transaction type share (2018 to Q2 2026)
SELECT txn_type,
       SUM(txn_count) AS total_txns,
       ROUND(100.0 * SUM(txn_count) / SUM(SUM(txn_count)) OVER (), 1) AS share_pct
FROM agg_transaction
GROUP BY txn_type
ORDER BY total_txns DESC;

Q4b: Transaction type share by year (2018-2025)

SELECT year, txn_type,
       ROUND(100.0 * SUM(txn_count) / SUM(SUM(txn_count)) OVER (PARTITION BY year), 1) AS share_pct
FROM agg_transaction
WHERE year < 2026
GROUP BY year, txn_type
ORDER BY year, txn_type;


-- Q5: Top 10 districts by transaction count (2018 to Q2 2026)
SELECT state, district,
       SUM(txn_count) AS total_txns,
       ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore
FROM map_transaction
GROUP BY state, district
ORDER BY total_txns DESC
LIMIT 10;


-- Q6: Transactions per registered user, by state (2025)
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


-- Q7: Top 3 districts in every state (2018 to Q2 2026)
SELECT * FROM (
    SELECT state, district,
           ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore,
           RANK() OVER (PARTITION BY state ORDER BY SUM(txn_amount) DESC) AS rnk
    FROM map_transaction
    GROUP BY state, district
) x
WHERE rnk <= 3
ORDER BY state, rnk;


-- Q8: Share of top states in total amount (concentration)
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


-- Q9: Average ticket size per state (amount / txns)
SELECT state,
       SUM(txn_count) AS total_txns,
       ROUND(SUM(txn_amount)::numeric / 1e7, 2) AS amount_crore,
       ROUND(SUM(txn_amount)::numeric / SUM(txn_count), 0) AS avg_ticket_rs
FROM map_transaction
GROUP BY state
ORDER BY amount_crore DESC
LIMIT 10;


-- Q10: H1 2026 vs H1 2025 growth (latest available data)
WITH h1 AS (
    SELECT year, SUM(txn_count) AS txns, SUM(txn_amount)::numeric AS amt
    FROM map_transaction
    WHERE quarter IN (1, 2) AND year IN (2025, 2026)
    GROUP BY year
)
SELECT year, txns,
       ROUND(amt / 1e7, 2) AS amount_crore,
       ROUND(100.0 * (txns - LAG(txns) OVER (ORDER BY year)) / LAG(txns) OVER (ORDER BY year), 1) AS txn_growth_pct,
       ROUND(100.0 * (amt - LAG(amt) OVER (ORDER BY year)) / LAG(amt) OVER (ORDER BY year), 1) AS amount_growth_pct
FROM h1
ORDER BY year;



-- Q11: Average ticket size by year (2018-2025)
SELECT year,
       SUM(txn_count) AS txns,
       ROUND(SUM(txn_amount)::numeric / SUM(txn_count), 0) AS avg_ticket_rs
FROM map_transaction
WHERE year < 2026
GROUP BY year
ORDER BY year;

-- Validation: do both tables give the same total transaction count?
SELECT (SELECT SUM(txn_count) FROM agg_transaction) AS agg_total,
       (SELECT SUM(txn_count) FROM map_transaction) AS map_total;