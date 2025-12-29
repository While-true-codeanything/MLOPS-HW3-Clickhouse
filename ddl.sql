CREATE DATABASE IF NOT EXISTS homework3;
USE homework3;

CREATE TABLE transactions_kafka
(
    transaction_time DateTime,
    merch           String,
    cat_id          String,
    amount          Float64,
    name_1          String,
    name_2          String,
    gender          String,
    street          String,
    one_city        String,
    us_state        String,
    post_code       String,
    lat             Float64,
    lon             Float64,
    population_city UInt32,
    jobs            String,
    merchant_lat    Float64,
    merchant_lon    Float64,
    target          UInt8
)

ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:29092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_transactions_group',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

CREATE TABLE transactions
(
    transaction_time DateTime CODEC(DoubleDelta, ZSTD(1)),
    merch           String CODEC(ZSTD(1)),
    cat_id          String CODEC(ZSTD(1)),
    amount          Float64,
    name_1          String CODEC(ZSTD(1)),
    name_2          String CODEC(ZSTD(1)),
    gender          String CODEC(ZSTD(1)),
    street          String CODEC(ZSTD(1)),
    one_city        String CODEC(ZSTD(1)),
    us_state        String CODEC(ZSTD(1)),
    post_code       String CODEC(ZSTD(1)),
    lat             Float64,
    lon             Float64,
    population_city UInt32 CODEC(T64, ZSTD(1)),
    jobs            String CODEC(ZSTD(1)),
    merchant_lat    Float64,
    merchant_lon    Float64,
    target          UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, transaction_time);

CREATE MATERIALIZED VIEW transactions_kafka_mv
TO transactions
AS
SELECT *
FROM transactions_kafka;
