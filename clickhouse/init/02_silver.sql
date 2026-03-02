-- Silver layer: PII fields are SHA256-hashed before reaching gold.
-- All non-PII columns pass through unchanged.

CREATE DATABASE IF NOT EXISTS silver;

CREATE TABLE IF NOT EXISTS silver.raw_borrows
(
    borrow_id        String,
    member_name      String,   -- hashed
    email            String,   -- hashed  (still usable as natural key)
    phone            String,   -- hashed
    product_line     String,
    title            String,
    barcode          String,
    branch           String,
    city             String,
    state            String,
    country          String,
    currency         String,
    borrow_date      Date,
    due_date         Date,
    return_date      Nullable(Date),
    rental_fee_local Decimal(10, 2),
    fine_local       Decimal(10, 2)
)
ENGINE = MergeTree()
ORDER BY (borrow_id, barcode);

INSERT INTO silver.raw_borrows
SELECT
    borrow_id,
    hex(SHA256(member_name)) AS member_name,
    hex(SHA256(email))       AS email,
    hex(SHA256(phone))       AS phone,
    product_line,
    title,
    barcode,
    branch,
    city,
    state,
    country,
    currency,
    borrow_date,
    due_date,
    return_date,
    rental_fee_local,
    fine_local
FROM bronze.raw_borrows;
