import csv
import json
from kafka import KafkaProducer

def main():
    producer = KafkaProducer(
        bootstrap_servers='kafka:9092',
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )

    with open('/data/train.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            producer.send('transactions_topic', row)

    producer.flush()

if __name__ == "__main__":
    main()
