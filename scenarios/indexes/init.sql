-- Index for Query 1:
-- Fetch latest orders for a customer ordered by created_at
CREATE INDEX idx_orders_customer_created_at
ON orders (customer_id, created_at DESC);

-- Index for Query 2:
-- Count paid orders in a recent time window
CREATE INDEX idx_orders_paid_created_at
ON orders (created_at)
WHERE status = 'paid';

-- Index for Query 3:
-- Aggregate orders by recent creation date
CREATE INDEX idx_orders_created_at
ON orders (created_at);
