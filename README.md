# Database Performance POC [Work In Progress]

## Objective
Evaluate PostgreSQL performance trade-offs from a backend perspective by applying different optimization strategies.

## Scenarios
- :white_check_mark: Baseline (no indexes)
- :white_check_mark: Index strategies
- :clock3: Partitioning
- :clock3: JSONB vs Relational
- :clock3: Denormalization

A lot of databases organize the data of entities using the primary key and an application can use this key to locate and retrieve data. In our `order` table exemple, an application can't use the Order ID primary key to retrieve order if it queries data solely by referencing the value of `status` and `create_at`. To perform a query such as this, the application might have to fetch and examine every order record, which could be a slow process. Many relational database support secondary indexes that is a separate data structure that's organized by one or more secondary key fields, and it indicates where the data for each indexed value is stored. **Here, in the index strategy scenario, we'll will use this approach to improve the performance of some queries**.

## Benchmark Queries

This query simulates a very common backend access pattern: retrieving the most recent orders for a specific customer, typically used in dashboards, order history pages, or customer support tools. It combines a filter by customer_id, an ORDER BY created_at DESC, and a LIMIT, which makes it highly sensitive to index design. Without a suitable composite index, PostgreSQL is forced to scan the entire table and sort the result set, leading to unnecessary I/O and CPU usage. This query is ideal for benchmarking because it clearly demonstrates the performance impact of proper indexing strategies versus full able scans.

```sql
SELECT *
FROM orders
WHERE customer_id = (
  SELECT customer_id FROM orders LIMIT 1
)
ORDER BY created_at DESC
LIMIT 20;
```

The second one filters data by a low-cardinality column status combined with a time range created_at. This pattern is intentionally
chosen because it highlights common indexing mistakes, such as indexing only the status column, which often performs poorly due to 
low selectivity. The query is well suited for benchmarking index strategies like composite or partial indexes and shows how filtering 
on temporal data can drastically affect performance when no efficient access path exists.

```sql
SELECT count(*)
FROM orders
WHERE status = 'paid'
  AND created_at >= now() - interval '30 days';
```

Last one simulates financial aggregation logic commonly found in backend systems, such as calculating revenue over a given period. 
It applies a time-based filter and performs a SUM aggregation over a NUMERIC column, which is computationally more expensive than
integer-based alternatives. This makes the query particularly useful for evaluating the cost of full table scans versus indexed
access on time-series data, as well as understanding the performance trade-offs of using precise numeric types for monetary values.
It also provides a realistic example of how aggregation workloads scale with data volume.

```sql
SELECT sum(amount)
FROM orders
WHERE created_at >= now() - interval '7 days';
```
## Results

| Query | Description | Baseline Execution Time | Indexed Execution Time |
|------|------------|---------------------|----------|
| Q1 | Fetch latest orders for a customer | **33.4 ms** | **0.07 ms** |
| Q2 | Count paid orders in the last 30 days | **64.7 ms** | **15.0 ms** |
| Q3 | Sum order amounts in the last 7 days | **70.8 ms** | **95.9 ms** |

## How to reproduce

How to run the benchmark:

```bash
chmod +x benchmarks/run_benchmarks.sh
./benchmarks/run_benchmarks.sh
```

## Project structure
```
├── docker-compose.yml
├── README.md
├── data/
│   └── seed.sql
├── benchmarks/
│   ├── queries.sql
│   └── run_benchmarks.sh
├── scenarios/
│   ├── baseline/
│   │   └── init.sql
│   ├── indexes/
│   │   └── init.sql
│   ├── partitions/
│   │   └── init.sql
│   ├── jsonb_vs_normalized/
│   │   └── init.sql
│   └── denormalization/
```
