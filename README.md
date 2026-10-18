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