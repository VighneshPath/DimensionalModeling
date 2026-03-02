#!/usr/bin/env python3
"""
ETL: bronze.raw_borrows  →  gold dimensional model
No silver tier — single clean source maps directly to dimensions + fact.

Requires: pip install clickhouse-connect
"""

import clickhouse_connect
from datetime import date
from decimal import Decimal

# ── Connection ────────────────────────────────────────────────────────────────

client = clickhouse_connect.get_client(
    host='localhost',
    port=8123,
    username='library',
    password='library123',
)

# ── Static FX rates (local currency → USD) ───────────────────────────────────
# dim_currency_conversion is not in the source; using fixed rates for now.

FX_TO_USD = {
    'USD': Decimal('1.0'),
    'INR': Decimal('0.01205'),   # ~83 INR/USD
    'EUR': Decimal('1.08'),
    'JPY': Decimal('0.00667'),   # ~150 JPY/USD
}

def to_usd(amount: Decimal, currency: str) -> Decimal:
    return round(amount * FX_TO_USD.get(currency, Decimal('1.0')), 4)

def make_date_key(d: date) -> int:
    """YYYYMMDD integer — compact, sortable, human-readable."""
    return int(d.strftime('%Y%m%d'))

def build_date_row(d: date) -> tuple:
    return (
        make_date_key(d),
        d,
        d.strftime('%A'),             # 'Monday', 'Tuesday', ...
        d.weekday() >= 5,             # is_weekend
        False,                        # is_public_holiday — no reference calendar
        d.month,
        (d.month - 1) // 3 + 1,      # quarter
        d.year,
    )

# ── Read bronze ───────────────────────────────────────────────────────────────

print('Reading silver.raw_borrows...')
bronze_rows = list(client.query('SELECT * FROM silver.raw_borrows').named_results())
print(f'  {len(bronze_rows)} rows loaded')

# ── Create gold schema + tables ───────────────────────────────────────────────

print('\nCreating gold schema...')
client.command('CREATE DATABASE IF NOT EXISTS gold')

client.command('''
    CREATE OR REPLACE TABLE gold.dim_member (
        member_key  UInt32,
        member_name String,
        email       String,
        phone       String
    ) ENGINE = MergeTree() ORDER BY member_key
''')

client.command('''
    CREATE OR REPLACE TABLE gold.dim_branch (
        branch_key     UInt32,
        branch_name    String,
        city           String,
        state_province String,
        country        String,
        local_currency String
    ) ENGINE = MergeTree() ORDER BY branch_key
''')

client.command('''
    CREATE OR REPLACE TABLE gold.dim_product (
        product_key  UInt32,
        barcode      String,
        title        String,
        product_line String
    ) ENGINE = MergeTree() ORDER BY product_key
''')

client.command('''
    CREATE OR REPLACE TABLE gold.dim_date (
        date_key          UInt32,
        full_date         Date,
        day_of_week       String,
        is_weekend        Bool,
        is_public_holiday Bool,
        month             UInt8,
        quarter           UInt8,
        year              UInt16
    ) ENGINE = MergeTree() ORDER BY date_key
''')

client.command('''
    CREATE OR REPLACE TABLE gold.fact_borrow_return (
        key               UInt32,
        member_key        UInt32,
        branch_key        UInt32,
        product_key       UInt32,
        borrow_date_key   UInt32,
        due_date_key      UInt32,
        return_date_key   Nullable(UInt32),
        fee_local         Decimal(10, 2),
        fee_usd           Decimal(10, 4),
        fine_amount_local Decimal(10, 2),
        fine_amount_usd   Decimal(10, 4),
        borrow_count      UInt8,
        days_late         Int32,
        is_lost           Bool,
        return_count      Nullable(UInt8)
    ) ENGINE = MergeTree() ORDER BY key
''')

# ── dim_member ────────────────────────────────────────────────────────────────
# Natural key: email (unique per person in the source data)
# membership_id and address are not in the borrow dataset

member_map = {}   # email → member_key
member_rows = []

for row in bronze_rows:
    email = row['email']
    if email not in member_map:
        key = len(member_map) + 1
        member_map[email] = key
        member_rows.append((key, row['member_name'], email, row['phone']))

client.insert(
    'gold.dim_member', member_rows,
    column_names=['member_key', 'member_name', 'email', 'phone'],
)
print(f'dim_member:         {len(member_rows)} rows')

# ── dim_branch ────────────────────────────────────────────────────────────────
# Natural key: branch name

branch_map = {}   # branch name → branch_key
branch_rows = []

for row in bronze_rows:
    branch = row['branch']
    if branch not in branch_map:
        key = len(branch_map) + 1
        branch_map[branch] = key
        branch_rows.append((key, branch, row['city'], row['state'], row['country'], row['currency']))

client.insert(
    'gold.dim_branch', branch_rows,
    column_names=['branch_key', 'branch_name', 'city', 'state_province', 'country', 'local_currency'],
)
print(f'dim_branch:         {len(branch_rows)} rows')

# ── dim_product ───────────────────────────────────────────────────────────────
# Natural key: barcode (unique per physical copy)

product_map = {}   # barcode → product_key
product_rows = []

for row in bronze_rows:
    barcode = row['barcode']
    if barcode not in product_map:
        key = len(product_map) + 1
        product_map[barcode] = key
        product_rows.append((key, barcode, row['title'], row['product_line']))

client.insert(
    'gold.dim_product', product_rows,
    column_names=['product_key', 'barcode', 'title', 'product_line'],
)
print(f'dim_product:        {len(product_rows)} rows')

# ── dim_date ──────────────────────────────────────────────────────────────────
# Collect every distinct date that appears across borrow_date, due_date, return_date

all_dates = set()
for row in bronze_rows:
    all_dates.add(row['borrow_date'])
    all_dates.add(row['due_date'])
    if row['return_date'] is not None:
        all_dates.add(row['return_date'])

date_rows = [build_date_row(d) for d in sorted(all_dates)]

client.insert(
    'gold.dim_date', date_rows,
    column_names=['date_key', 'full_date', 'day_of_week', 'is_weekend',
                  'is_public_holiday', 'month', 'quarter', 'year'],
)
print(f'dim_date:           {len(date_rows)} rows')

# ── fact_borrow_return ────────────────────────────────────────────────────────

fact_rows = []

for i, row in enumerate(bronze_rows, start=1):
    currency    = row['currency']
    fee_local   = row['rental_fee_local']
    fine_local  = row['fine_local']
    return_date = row['return_date']
    due_date    = row['due_date']

    if return_date is not None:
        days_late        = max(0, (return_date - due_date).days)
        return_date_key  = make_date_key(return_date)
        return_count     = 1
    else:
        days_late        = 0
        return_date_key  = None
        return_count     = None

    fact_rows.append((
        i,
        member_map[row['email']],
        branch_map[row['branch']],
        product_map[row['barcode']],
        make_date_key(row['borrow_date']),
        make_date_key(due_date),
        return_date_key,
        fee_local,
        to_usd(fee_local, currency),
        fine_local,
        to_usd(fine_local, currency),
        1,      # borrow_count always 1
        days_late,
        False,  # is_lost — not determinable from source data
        return_count,
    ))

client.insert(
    'gold.fact_borrow_return', fact_rows,
    column_names=[
        'key', 'member_key', 'branch_key', 'product_key',
        'borrow_date_key', 'due_date_key', 'return_date_key',
        'fee_local', 'fee_usd', 'fine_amount_local', 'fine_amount_usd',
        'borrow_count', 'days_late', 'is_lost', 'return_count',
    ],
)
print(f'fact_borrow_return: {len(fact_rows)} rows')

print('\nETL complete.')
