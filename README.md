# Домашнее задание MLOps: Kafka → ClickHouse

Проект реализует конвейер, в котором данные из CSV-файла отправляются в Kafka с помощью Python-продюсера, а ClickHouse читает данные из Kafka-топика через таблицу ENGINE = Kafka и материализованное представление. Реализованы создание инфраструктуры, загрузка данных, SQL-запрос и оптимизация структуры хранения.

## Структура проекта
.
├── data/                          # директория для train.csv (не хранится в git)
├── kafka_producer/
│   ├── Dockerfile                 # образ для Kafka-продюсера
│   └── producer.py                # отправка строк CSV в Kafka
├── clickhouse/
│   ├── ddl_initial.sql            # начальный DDL: таблица Kafka, MergeTree, MV
│   ├── ddl_optimized.sql          # оптимизированная схема таблицы
│   ├── query.sql                  # SQL-запрос: категория с максимальной транзакцией по штату
│   └── result_max_category_by_state.csv
├── docker-compose.yml
├── requirements.txt
└── README.md

## Подготовка данных
Файл train.csv необходимо скачать с Kaggle:
https://www.kaggle.com/competitions/teta-ml-1-2025/data

После скачивания положить файл в директорию:

data/train.csv

Файл отсутствует в репозитории из-за ограничения GitHub на максимальный размер файла (100MB).

## Запуск проекта

### 1. Запуск Kafka, Zookeeper и ClickHouse
docker-compose up -d zookeeper kafka clickhouse

Проверка контейнеров:
docker ps

### 2. Создание таблиц в ClickHouse
docker exec -i mlopshw4-clickhouse-1 clickhouse-client < clickhouse/ddl_initial.sql

Проверить список таблиц:
docker exec -it mlopshw4-clickhouse-1 clickhouse-client -q "SHOW TABLES FROM teta"

Ожидаемые таблицы:
- kafka_transactions
- mv_kafka_to_transactions
- transactions

### 3. Загрузка CSV в Kafka и запись в ClickHouse
Запуск продюсера:
docker-compose run --rm producer

Проверить количество записей:
docker exec -it mlopshw4-clickhouse-1 clickhouse-client -q "SELECT count() FROM teta.transactions"

### 4. Выполнение SQL-запроса по заданию
docker exec -it mlopshw4-clickhouse-1 clickhouse-client -d teta -q "$(cat clickhouse/query.sql)"

Запрос возвращает категорию с максимальной транзакцией и ее сумму для каждого штата.

### 5. Экспорт результата SQL-запроса в CSV
docker exec -i mlopshw4-clickhouse-1 clickhouse-client -d teta --format CSV --query="$(cat clickhouse/query.sql)" > clickhouse/result_max_category_by_state.csv

## Оптимизация хранения (DDL)
Оптимизированная таблица из ddl_optimized.sql использует:
- LowCardinality(String) для строковых колонок  
- PARTITION BY state  
- ORDER BY (state, category)

Применение оптимизированного DDL:
docker exec -i mlopshw4-clickhouse-1 clickhouse-client < clickhouse/ddl_optimized.sql

## Примечания
- Проект полностью контейнеризован через Docker Compose.
- Данные необходимо скачивать вручную и помещать в директорию data/.
- Все шаги воспроизводимы: инфраструктура поднимается, данные загружаются и запросы выполняются без изменений.

