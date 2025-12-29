FROM python:3.12-slim

WORKDIR /app

COPY producer.py /app/producer.py
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "producer.py"]
