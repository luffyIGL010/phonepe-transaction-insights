# PhonePe Transaction Insights

End-to-end analysis of PhonePe Pulse data using Python, PostgreSQL & Tableau.

## Problem
Understand how digital payments are growing across Indian states and districts: which regions drive the most transactions, how usage changes by quarter, and what this means for business decisions.

## Data
Source: [PhonePe Pulse](https://github.com/PhonePe/pulse) (official open data).
The raw data is not included in this repo. Clone the original repo to reproduce.

| Table | Rows | Description |
|---|---|---|
| agg_transaction | 3,671 | State-wise transaction count by type (P2P, Retail, Utility) |
| agg_user | 1,224 | State-wise registered users |
| map_transaction | 26,616 | District-wise transaction count and amount |

## Tools
Python (pandas), PostgreSQL, SQL, Tableau Public

## Approach
1. Extracted nested JSON files into structured tables (`data_extraction.py`)
2. Cleaned and validated the data (duplicates, nulls, state names)
3. Loaded into PostgreSQL and analysed with SQL
4. Built an interactive dashboard in Tableau Public

## Key Insights
_(Day 4-6 ke baad yahan likhenge)_

## Dashboard
_(Tableau Public link yahan aayega)_

## How to run
```bash
git clone https://github.com/PhonePe/pulse.git
python -m venv venv && source venv/bin/activate
pip install pandas sqlalchemy psycopg2-binary
python data_extraction.py
```

## Credits
Data: PhonePe Pulse, under their open data terms.
## Key Insights

Data: PhonePe Pulse, 2018 Q1 to 2026 Q2. Annual figures use 2018-2025 (2026 is incomplete).

1. **Scale:** Transactions grew from 1.1B (2018) to 128.5B (2025); value grew from Rs 1.6 lakh crore to Rs 155.4 lakh crore.
2. **Growth is maturing:** Yearly value growth slowed from 125.8% (2021) to 19.8% (2025). H1 2026 transaction count is up 23.5% vs H1 2025.
3. **Smaller payments:** Average ticket size peaked around Rs 1,827 (2020) and fell to about Rs 1,209 (2025), as transaction count grew faster than value.
4. **Geography:** Karnataka, Maharashtra, Telangana and Andhra Pradesh lead by value. The top 10 states account for about 79% of all transactions. Maharashtra leads in volume, Karnataka in value.
5. **Engagement:** Telangana (365), Andhra Pradesh (320) and Karnataka (306) have the most transactions per registered user in 2025; Tamil Nadu (96) and Gujarat (115) are among the lowest.
6. **Payment mix:** Retail is 58.7% of transactions, P2P 34.0%, Utility 7.2% (2018 to Q2 2026).
7. **Data check:** Transaction totals from the aggregated and district tables match exactly (437.4B).

Note: causes (for example why ticket size is falling) are hypotheses, not proven by this data.