import os, json
import pandas as pd

ROOT = "data"
OUT = "output"
os.makedirs(OUT, exist_ok=True)


def clean_state(s):
    return s.replace("-", " ").title()


def iter_files(base):
    """base/<state>/<year>/<quarter>.json ko loop karta hai"""
    if not os.path.exists(base):
        print(f"Skip (not found): {base}")
        return
    for state in sorted(os.listdir(base)):
        sp = os.path.join(base, state)
        if not os.path.isdir(sp):
            continue
        for year in sorted(os.listdir(sp)):
            yp = os.path.join(sp, year)
            if not os.path.isdir(yp):
                continue
            for f in sorted(os.listdir(yp)):
                if f.endswith(".json"):
                    with open(os.path.join(yp, f)) as fh:
                        yield clean_state(state), int(year), int(f.split(".")[0]), json.load(fh)


def agg_transaction():
    base = f"{ROOT}/aggregated/transaction/country/india/state"
    rows = []
    for state, year, q, js in iter_files(base):
        for item in js["data"].get("transactionData") or []:
            insts = item.get("paymentInstruments") or [{}]
            rows.append([state, year, q, item["name"], insts[0].get("count")])
    return pd.DataFrame(rows, columns=["state", "year", "quarter", "txn_type", "txn_count"])


def agg_user():
    base = f"{ROOT}/aggregated/user/country/india/state"
    rows = []
    for state, year, q, js in iter_files(base):
        agg = js["data"].get("aggregated") or {}
        rows.append([state, year, q, agg.get("registeredCount")])
    return pd.DataFrame(rows, columns=["state", "year", "quarter", "registered_users"])


def map_transaction():
    base = f"{ROOT}/map/transaction/hover/country/india/state"
    rows = []
    for state, year, q, js in iter_files(base):
        for item in js["data"].get("hoverDataList") or []:
            m = (item.get("metric") or [{}])[0]
            rows.append([state, year, q, item["name"].title(), m.get("count"), m.get("amount")])
    return pd.DataFrame(rows, columns=["state", "year", "quarter", "district", "txn_count", "txn_amount"])


if __name__ == "__main__":
    tables = {
        "agg_transaction": agg_transaction(),
        "agg_user": agg_user(),
        "map_transaction": map_transaction(),
    }
    for name, df in tables.items():
        df.to_csv(f"{OUT}/{name}.csv", index=False)
        print(f"{name}: {df.shape} | nulls: {int(df.isna().sum().sum())}")