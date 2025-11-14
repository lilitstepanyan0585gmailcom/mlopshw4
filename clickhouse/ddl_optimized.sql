CREATE TABLE IF NOT EXISTS teta.transactions_opt
(
    state LowCardinality(String),
    category LowCardinality(String),
    amount Float64
)
ENGINE = MergeTree
PARTITION BY state
ORDER BY (state, category);
