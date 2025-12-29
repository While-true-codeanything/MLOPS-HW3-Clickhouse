## Описание

Проект предназначен для загрузки транзакционных данных из CSV-файла в ClickHouse через Kafka
и выполнения аналитических SQL-запросов.

Решение реализовано как end-to-end pipeline:
- данные из CSV отправляются в Kafka с помощью Python-producer
- ClickHouse читает сообщения из Kafka-топика
- данные сохраняются в оптимизированную таблицу MergeTree
- выполняется запрос для получения категории наибольшей транзакции по каждому штату США


Архитектура проекта
```
├── docker-compose.yml
├── Dockerfile
├── README.md
├── ddl.sql              # Cкрипт для инициализации ClickHouse
├── query.sql            # SQL-запрос для топ транзакций упорядоченных по штатам
├── producer.py          # Producer для загрузки данных
├── requirements.txt
│
├── input/
│   └── train.csv        # СSV-файл с транзакциями (ВАЖНО: Это сильно укороченная версия, а не исходный файл. При желании, его можно заменить, но для быстроты работы пока стоит короткая версия)
```


## Оптимизация хранения данных

Для ускорения использвоал следующие оптимизации:

- PARTITION по transaction_time

- ORDER BY под основной запрос

- LowCardinality для части строковых колонок(подходящих по его логику)

- Сжатие с CODEC ZSTD для строк


## Сборка и запуск

Требования:
- Docker 20.10+
- Docker Compose 2.0+

Запуск проекта:
> docker compose up --build


Инициализация ClickHouse

> docker cp ddl.sql clickhouse:/ddl.sql
> 
> docker exec -it clickhouse clickhouse-client --user click --password click --queries-file /ddl.sql

Вход в поднятый ClickHouse

> docker exec -it clickhouse clickhouse-client --user click --password click

Вычисление результирующего CSV файла с запросом
> docker cp query_transactions.sql clickhouse:/query_transactions.sql
> 
> docker exec -it clickhouse clickhouse-client --user click --password click --queries-file /query_transactions.sql --format CSVWithNames | Out-File result.csv
