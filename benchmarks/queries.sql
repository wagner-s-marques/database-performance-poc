-- Warm up
SELECT count(*) FROM orders;

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = (
  SELECT customer_id FROM orders LIMIT 1
)
ORDER BY created_at DESC
LIMIT 20;

EXPLAIN ANALYZE
SELECT count(*)
FROM orders
WHERE status = 'paid'
  AND created_at >= now() - interval '30 days';

EXPLAIN ANALYZE
SELECT sum(amount)
FROM orders
WHERE created_at >= now() - interval '7 days';
