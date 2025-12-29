import logging
import os
import json
import sys

import pandas as pd
from confluent_kafka import Producer

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)

BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:29092")
TOPIC = os.getenv("KAFKA_TRANSACTIONS_TOPIC", "transactions")


def main():
    logger.info("Starting Kafka Train producer")
    producer = Producer({"bootstrap.servers": BOOTSTRAP})

    df = pd.read_csv("/app/input/train.csv")

    if "transaction_time" in df.columns:
        df["transaction_time"] = pd.to_datetime(
            df["transaction_time"], errors="coerce"
        ).dt.strftime("%Y-%m-%d %H:%M:%S")

    cr = 0
    total = len(df)
    for _, row in df.iterrows():
        producer.produce(
            TOPIC,
            value=json.dumps(row.where(pd.notnull(row), None).to_dict(), ensure_ascii=False).encode("utf-8"),
        )
        producer.poll(0)

        cr += 1
        if cr % 25_000 == 0:
            logger.info(f"Sent {cr}/{total} messages")

    producer.flush(20)
    logger.info(f"Producer finished sending messages")


if __name__ == "__main__":
    main()
