DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- =========================================================================
-- Schema
-- =========================================================================

CREATE TABLE customers (
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           TEXT NOT NULL,
    category       TEXT NOT NULL,
    price          NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (id),
    order_date  DATE NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items (
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id   INTEGER NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products (id),
    quantity   INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_order_date ON orders (order_date);
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);

-- =========================================================================
-- Sample data: customers (15)
-- =========================================================================

INSERT INTO customers (name, email, created_at) VALUES
    ('Alice Johnson',    'alice.johnson@example.com',    '2025-01-15'),
    ('Brian Lee',        'brian.lee@example.com',        '2025-02-03'),
    ('Carla Mendes',     'carla.mendes@example.com',     '2025-02-20'),
    ('David Kim',        'david.kim@example.com',        '2025-03-11'),
    ('Emma Davis',       'emma.davis@example.com',       '2025-03-28'),
    ('Farhan Ahmed',     'farhan.ahmed@example.com',     '2025-04-09'),
    ('Grace Chen',       'grace.chen@example.com',       '2025-04-30'),
    ('Hassan Ali',       'hassan.ali@example.com',       '2025-05-14'),
    ('Isabella Rossi',   'isabella.rossi@example.com',   '2025-06-02'),
    ('Jack Wilson',      'jack.wilson@example.com',      '2025-06-19'),
    ('Karen O''Brien',   'karen.obrien@example.com',     '2025-07-07'),
    ('Liam Nguyen',      'liam.nguyen@example.com',      '2025-08-01'),
    ('Maria Garcia',     'maria.garcia@example.com',     '2025-09-15'),
    ('Noah Thompson',    'noah.thompson@example.com',    '2025-11-02'),
    ('Olivia Brown',     'olivia.brown@example.com',     '2026-01-20');

-- =========================================================================
-- Sample data: products (20 across 5 categories)
-- =========================================================================

INSERT INTO products (name, category, price, stock_quantity) VALUES
    -- Electronics
    ('Wireless Bluetooth Earbuds',       'Electronics',       49.99, 150),
    ('Smart Fitness Watch',              'Electronics',      129.99,  80),
    ('USB-C Fast Charger 65W',           'Electronics',       24.99, 200),
    ('Portable Bluetooth Speaker',       'Electronics',       59.99, 120),
    ('Noise Cancelling Headphones',      'Electronics',      199.99,  45),
    -- Clothing
    ('Men''s Classic Fit T-Shirt',       'Clothing',          19.99, 300),
    ('Women''s Running Leggings',        'Clothing',          34.99, 180),
    ('Unisex Hoodie',                    'Clothing',          44.99, 150),
    ('Denim Jacket',                     'Clothing',          79.99,  60),
    -- Home & Kitchen
    ('Stainless Steel Cookware Set',     'Home & Kitchen',   149.99,  40),
    ('Electric Kettle 1.7L',             'Home & Kitchen',    34.99,  90),
    ('Memory Foam Pillow',               'Home & Kitchen',    29.99, 110),
    ('Non-Stick Frying Pan',             'Home & Kitchen',    24.99, 130),
    -- Books
    ('The Pragmatic Programmer',         'Books',             39.99,  75),
    ('Atomic Habits',                    'Books',             17.99, 200),
    ('Sapiens: A Brief History of Humankind', 'Books',         21.99, 140),
    ('Clean Code',                       'Books',             34.99,  65),
    -- Sports & Outdoors
    ('Yoga Mat Premium',                 'Sports & Outdoors',  29.99, 160),
    ('Adjustable Dumbbell Set',          'Sports & Outdoors', 199.99,  30),
    ('Insulated Water Bottle 32oz',      'Sports & Outdoors',  19.99, 220);

-- =========================================================================
-- Sample data: orders (32, spread across the last ~6 months)
--
-- Order patterns are deliberately uneven:
--   - Alice, Brian, Carla, David, Isabella, Jack, Liam, Maria all have an
--     order within the last 3 months (active customers).
--   - Emma, Farhan, Grace, Hassan, Karen, Noah last ordered more than 3
--     months ago (lapsed customers).
--   - Olivia has never placed an order at all (edge case: a customer with
--     zero rows in `orders`, not just an old one -- easy to miss with a
--     naive query).
-- =========================================================================

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1,  '2026-03-05', 'delivered'),  -- 1  Alice
    (1,  '2026-05-20', 'delivered'),  -- 2  Alice
    (1,  '2026-07-10', 'delivered'),  -- 3  Alice
    (1,  '2026-08-12', 'shipped'),    -- 4  Alice
    (2,  '2026-02-14', 'delivered'),  -- 5  Brian
    (2,  '2026-06-01', 'delivered'),  -- 6  Brian
    (2,  '2026-08-05', 'pending'),    -- 7  Brian
    (3,  '2026-04-22', 'delivered'),  -- 8  Carla
    (3,  '2026-07-30', 'shipped'),    -- 9  Carla
    (4,  '2026-03-15', 'cancelled'),  -- 10 David
    (4,  '2026-03-16', 'delivered'),  -- 11 David
    (4,  '2026-08-14', 'pending'),    -- 12 David
    (5,  '2026-02-10', 'delivered'),  -- 13 Emma
    (5,  '2026-03-01', 'delivered'),  -- 14 Emma
    (6,  '2026-02-25', 'delivered'),  -- 15 Farhan
    (7,  '2026-03-20', 'delivered'),  -- 16 Grace
    (7,  '2026-04-05', 'cancelled'),  -- 17 Grace
    (8,  '2026-05-01', 'delivered'),  -- 18 Hassan
    (8,  '2026-05-10', 'delivered'),  -- 19 Hassan
    (9,  '2026-06-12', 'delivered'),  -- 20 Isabella
    (9,  '2026-07-22', 'shipped'),    -- 21 Isabella
    (10, '2026-05-25', 'delivered'),  -- 22 Jack
    (10, '2026-08-01', 'pending'),    -- 23 Jack
    (11, '2026-02-05', 'delivered'),  -- 24 Karen
    (11, '2026-02-28', 'delivered'),  -- 25 Karen
    (11, '2026-04-10', 'delivered'),  -- 26 Karen
    (12, '2026-06-30', 'delivered'),  -- 27 Liam
    (12, '2026-07-15', 'cancelled'),  -- 28 Liam
    (12, '2026-08-10', 'delivered'),  -- 29 Liam
    (13, '2026-07-01', 'delivered'),  -- 30 Maria
    (13, '2026-08-15', 'pending'),    -- 31 Maria
    (14, '2026-03-10', 'delivered');  -- 32 Noah
    -- customer 15 (Olivia Brown) intentionally has no orders

-- =========================================================================
-- Sample data: order_items (line items for each order above)
-- =========================================================================

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    -- Order 1 (Alice)
    (1,  2,  1, 129.99),
    (1,  12, 2, 29.99),
    -- Order 2 (Alice)
    (2,  15, 1, 17.99),
    (2,  18, 1, 29.99),
    -- Order 3 (Alice)
    (3,  1,  1, 49.99),
    -- Order 4 (Alice)
    (4,  20, 2, 19.99),
    (4,  16, 1, 21.99),
    -- Order 5 (Brian)
    (5,  6,  3, 19.99),
    (5,  8,  1, 44.99),
    -- Order 6 (Brian)
    (6,  3,  2, 24.99),
    -- Order 7 (Brian)
    (7,  19, 1, 199.99),
    -- Order 8 (Carla)
    (8,  10, 1, 149.99),
    (8,  13, 1, 24.99),
    -- Order 9 (Carla)
    (9,  14, 1, 39.99),
    (9,  17, 1, 34.99),
    -- Order 10 (David, cancelled)
    (10, 4,  1, 59.99),
    -- Order 11 (David)
    (11, 5,  1, 199.99),
    -- Order 12 (David)
    (12, 7,  2, 34.99),
    (12, 9,  1, 79.99),
    -- Order 13 (Emma)
    (13, 11, 1, 34.99),
    (13, 12, 1, 29.99),
    -- Order 14 (Emma)
    (14, 15, 2, 17.99),
    (14, 16, 1, 21.99),
    -- Order 15 (Farhan)
    (15, 6,  2, 19.99),
    (15, 20, 3, 19.99),
    -- Order 16 (Grace)
    (16, 2,  1, 129.99),
    -- Order 17 (Grace, cancelled)
    (17, 19, 1, 199.99),
    -- Order 18 (Hassan)
    (18, 14, 1, 39.99),
    (18, 15, 1, 17.99),
    (18, 16, 1, 21.99),
    -- Order 19 (Hassan)
    (19, 17, 1, 34.99),
    -- Order 20 (Isabella)
    (20, 1,  1, 49.99),
    (20, 3,  1, 24.99),
    -- Order 21 (Isabella)
    (21, 18, 2, 29.99),
    (21, 20, 2, 19.99),
    -- Order 22 (Jack)
    (22, 8,  1, 44.99),
    (22, 9,  1, 79.99),
    -- Order 23 (Jack)
    (23, 4,  1, 59.99),
    -- Order 24 (Karen)
    (24, 10, 1, 149.99),
    -- Order 25 (Karen)
    (25, 11, 1, 34.99),
    (25, 13, 2, 24.99),
    -- Order 26 (Karen)
    (26, 6,  1, 19.99),
    (26, 7,  1, 34.99),
    -- Order 27 (Liam)
    (27, 19, 1, 199.99),
    -- Order 28 (Liam, cancelled)
    (28, 5,  1, 199.99),
    -- Order 29 (Liam)
    (29, 18, 1, 29.99),
    (29, 20, 4, 19.99),
    -- Order 30 (Maria)
    (30, 14, 1, 39.99),
    (30, 15, 4, 17.99),
    -- Order 31 (Maria)
    (31, 16, 2, 21.99),
    (31, 17, 1, 34.99),
    -- Order 32 (Noah)
    (32, 2,  1, 129.99),
    (32, 12, 1, 29.99);
