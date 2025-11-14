CREATE DATABASE IF NOT EXISTS teta;

CREATE TABLE IF NOT EXISTS teta.kafka_transactions
(
    state String,
    category String,
    amount Float64
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions_topic',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

CREATE TABLE IF NOT EXISTS teta.transactions
(
    state String,
    category String,
    amount Float64
)
ENGINE = MergeTree
ORDER BY (state, category);

CREATE MATERIALIZED VIEW IF NOT EXISTS teta.mv_kafka_to_transactions
TO teta.transactions
AS
SELECT
    state,
    category,
    amount
FROM teta.kafka_transactions;
