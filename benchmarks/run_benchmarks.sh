#!/usr/bin/env bash
set -e

BASELINE_URL="postgres://app:app@localhost:5432/appdb"
INDEXES_URL="postgres://app:app@localhost:5433/appdb"

RESULTS_DIR="$(dirname "$0")/results"
QUERIES_FILE="$(dirname "$0")/queries.sql"

mkdir -p "$RESULTS_DIR"

echo " Running benchmark on BASELINE..."
psql "$BASELINE_URL" \
  -v ON_ERROR_STOP=1 \
  -f "$QUERIES_FILE" \
  > "$RESULTS_DIR/baseline.txt"

echo "Running benchmark on INDEXES..."
psql "$INDEXES_URL" \
  -v ON_ERROR_STOP=1 \
  -f "$QUERIES_FILE" \
  > "$RESULTS_DIR/indexes.txt"

echo "Benchmark completed."
echo "Results saved in benchmarks/results/"
