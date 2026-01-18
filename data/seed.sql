CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

INSERT INTO orders (id, customer_id, amount, status, created_at, updated_at)
SELECT
  gen_random_uuid()::TEXT,
  gen_random_uuid()::TEXT,
  round((random() * 5000 + 10)::numeric, 2),
  CASE
    WHEN random() < 0.60 THEN 'paid'
    WHEN random() < 0.80 THEN 'pending'
    WHEN random() < 0.95 THEN 'failed'
    ELSE 'refunded'
  END,
  now() - (random() * interval '180 days'),
  now()
FROM generate_series(1, 1_000_000);
