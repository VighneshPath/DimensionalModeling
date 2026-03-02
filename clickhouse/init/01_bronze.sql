-- Bronze layer: raw data exactly as it appears in the problem statement
-- One row per borrowed physical copy per borrow transaction

CREATE DATABASE IF NOT EXISTS bronze;

CREATE TABLE IF NOT EXISTS bronze.raw_borrows
(
    borrow_id        String,
    member_name      String,
    email            String,
    phone            String,
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
    return_date      Nullable(Date),   -- NULL means not yet returned
    rental_fee_local Decimal(10, 2),
    fine_local       Decimal(10, 2)
)
ENGINE = MergeTree()
ORDER BY (borrow_id, barcode);

INSERT INTO bronze.raw_borrows VALUES
('B1001', 'Amol',  'amol@example.com', '+91-111', 'Book',     'Clean Code',         'BC101', 'Pune Central',     'Pune',     'Maharashtra',      'India',   'INR', '2026-01-01', '2026-01-15', '2026-01-14',  0,   0),
('B1001', 'Amol',  'amol@example.com', '+91-111', 'Book',     'DDD',                'BC205', 'Pune Central',     'Pune',     'Maharashtra',      'India',   'INR', '2026-01-01', '2026-01-15', '2026-01-20',  0,  50),
('B1001', 'Amol',  'amol@example.com', '+91-111', 'Magazine', 'NatGeo Jan',         'MG330', 'Pune Central',     'Pune',     'Maharashtra',      'India',   'INR', '2026-01-01', '2026-01-07', '2026-01-07', 10,   0),
('B1002', 'Sarah', 'sarah@us.com',     '+1-222',  'Book',     'Dune',               'US778', 'Austin Public',    'Austin',   'Texas',            'USA',     'USD', '2026-01-03', '2026-01-17', '2026-01-16',  0,   0),
('B1002', 'Sarah', 'sarah@us.com',     '+1-222',  'Journal',  'AI Monthly',         'JR900', 'Austin Public',    'Austin',   'Texas',            'USA',     'USD', '2026-01-03', '2026-01-10', '2026-01-15',  5,  30),
('B1003', 'Kenji', 'kenji@jp.com',     '+81-333', 'Book',     'Kafka on Shore',     'JP991', 'Tokyo East',       'Tokyo',    'Tokyo Prefecture', 'Japan',   'JPY', '2026-01-05', '2026-01-19', '2026-01-28',  0, 300),
('B1004', 'Lars',  'lars@de.com',      '+49-444', 'Book',     'Sapiens',            'DE551', 'Berlin Mitte',     'Berlin',   'Berlin',           'Germany', 'EUR', '2026-01-06', '2026-01-20', NULL,           0,   0),
('B1004', 'Lars',  'lars@de.com',      '+49-444', 'Magazine', 'Der Spiegel',        'MG880', 'Berlin Mitte',     'Berlin',   'Berlin',           'Germany', 'EUR', '2026-01-06', '2026-01-10', '2026-01-09',  4,   0),
('B1005', 'Amol',  'amol@example.com', '+91-111', 'Book',     'Refactoring',        'BC333', 'Mumbai South',     'Mumbai',   'Maharashtra',      'India',   'INR', '2026-01-08', '2026-01-22', '2026-01-21',  0,   0),
('B1005', 'Amol',  'amol@example.com', '+91-111', 'Journal',  'IEEE Software',      'JR111', 'Mumbai South',     'Mumbai',   'Maharashtra',      'India',   'INR', '2026-01-08', '2026-01-15', '2026-01-25',  0,  80),
('B1006', 'Maria', 'maria@us.com',     '+1-555',  'Book',     'Clean Architecture', 'US555', 'New York Central', 'New York', 'New York',         'USA',     'USD', '2026-01-10', '2026-01-24', '2026-02-10',  0, 200),
('B1006', 'Maria', 'maria@us.com',     '+1-555',  'Magazine', 'Time Weekly',        'MG771', 'New York Central', 'New York', 'New York',         'USA',     'USD', '2026-01-10', '2026-01-14', '2026-01-13',  6,   0),
('B1007', 'Ravi',  'ravi@in.com',      '+91-666', 'Book',     'Mythical Man-Month', 'BC222', 'Pune Central',     'Pune',     'Maharashtra',      'India',   'INR', '2026-01-11', '2026-01-25', '2026-01-24',  0,   0),
('B1007', 'Ravi',  'ravi@in.com',      '+91-666', 'Magazine', 'India Today',        'MG550', 'Pune Central',     'Pune',     'Maharashtra',      'India',   'INR', '2026-01-11', '2026-01-18', '2026-01-20',  8,  20),
('B1008', 'John',  'john@us.com',      '+1-777',  'Book',     'DDD',                'US111', 'Dallas Downtown',  'Dallas',   'Texas',            'USA',     'USD', '2026-01-12', '2026-01-26', '2026-01-25',  0,   0),
('B1008', 'John',  'john@us.com',      '+1-777',  'Journal',  'ACM Queue',          'JR333', 'Dallas Downtown',  'Dallas',   'Texas',            'USA',     'USD', '2026-01-12', '2026-01-19', '2026-01-30',  3,  60),
('B1009', 'Yuki',  'yuki@jp.com',      '+81-888', 'Book',     'Norwegian Wood',     'JP555', 'Tokyo East',       'Tokyo',    'Tokyo Prefecture', 'Japan',   'JPY', '2026-01-13', '2026-01-27', '2026-01-26',  0,   0),
('B1010', 'Klaus', 'klaus@de.com',     '+49-999', 'Book',     'Clean Code',         'DE222', 'Munich Central',   'Munich',   'Bavaria',          'Germany', 'EUR', '2026-01-14', '2026-01-28', '2026-02-05',  0, 120),
('B1010', 'Klaus', 'klaus@de.com',     '+49-999', 'Magazine', 'Auto Bild',          'MG990', 'Munich Central',   'Munich',   'Bavaria',          'Germany', 'EUR', '2026-01-14', '2026-01-21', '2026-01-21',  5,   0),
('B1011', 'Amol',  'amol@example.com', '+91-111', 'Book',     'Dune',               'BC444', 'Pune West',        'Pune',     'Maharashtra',      'India',   'INR', '2026-01-15', '2026-01-29', '2026-01-29',  0,   0),
('B1011', 'Amol',  'amol@example.com', '+91-111', 'Journal',  'Data Eng Weekly',    'JR777', 'Pune West',        'Pune',     'Maharashtra',      'India',   'INR', '2026-01-15', '2026-01-22', '2026-01-28',  0,  40),
('B1012', 'Sarah', 'sarah@us.com',     '+1-222',  'Book',     'Sapiens',            'US999', 'Austin Public',    'Austin',   'Texas',            'USA',     'USD', '2026-01-16', '2026-01-30', '2026-02-05',  0,  70),
('B1013', 'Kenji', 'kenji@jp.com',     '+81-333', 'Magazine', 'Anime World',        'MG123', 'Tokyo East',       'Tokyo',    'Tokyo Prefecture', 'Japan',   'JPY', '2026-01-17', '2026-01-24', '2026-01-24',  7,   0),
('B1014', 'Lars',  'lars@de.com',      '+49-444', 'Journal',  'EU Tech Review',     'JR555', 'Berlin Mitte',     'Berlin',   'Berlin',           'Germany', 'EUR', '2026-01-18', '2026-01-25', '2026-02-02',  0,  40),
('B1015', 'Maria', 'maria@us.com',     '+1-555',  'Book',     'Refactoring',        'US222', 'New York Central', 'New York', 'New York',         'USA',     'USD', '2026-01-19', '2026-02-02', '2026-02-02',  0,   0),
('B1015', 'Maria', 'maria@us.com',     '+1-555',  'Magazine', 'Vogue',              'MG700', 'New York Central', 'New York', 'New York',         'USA',     'USD', '2026-01-19', '2026-01-26', '2026-01-27', 10,  10),
('B1016', 'Ravi',  'ravi@in.com',      '+91-666', 'Book',     'Clean Architecture', 'BC909', 'Mumbai South',     'Mumbai',   'Maharashtra',      'India',   'INR', '2026-01-20', '2026-02-03', '2026-02-01',  0,   0),
('B1017', 'John',  'john@us.com',      '+1-777',  'Book',     'Sapiens',            'US333', 'Dallas Downtown',  'Dallas',   'Texas',            'USA',     'USD', '2026-01-21', '2026-02-04', NULL,           0,   0),
('B1018', 'Yuki',  'yuki@jp.com',      '+81-888', 'Journal',  'Manga Studies',      'JR222', 'Tokyo East',       'Tokyo',    'Tokyo Prefecture', 'Japan',   'JPY', '2026-01-22', '2026-01-29', '2026-02-10',  0,  90);
