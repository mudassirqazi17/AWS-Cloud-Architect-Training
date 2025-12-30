from kafka import KafkaConsumer
import boto3
import json
import time

# Kafka broker on your EC2 instance
BROKER = "172.31.20.80:19092"

# S3 bucket names you created
BUCKET_STRUCTURED = "structured-data-172-31-20-80"
BUCKET_SEMI = "semi-structured-data-172-31-20-80"
BUCKET_UNSTRUCTURED = "unstructured-data-172-31-20-80"

# Kafka Consumers for each topic
structured_consumer = KafkaConsumer(
    "structured-topic",
    bootstrap_servers=[BROKER],
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
    enable_auto_commit=True,
)

semi_consumer = KafkaConsumer(
    "semi-structured-topic",
    bootstrap_servers=[BROKER],
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
    enable_auto_commit=True,
)

unstructured_consumer = KafkaConsumer(
    "unstructured-topic",
    bootstrap_servers=[BROKER],
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
    enable_auto_commit=True,
)

# AWS S3 Client
s3 = boto3.client("s3")


def upload_data_to_s3(bucket, key, data):
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(data),
    )
    print(f"✔ Uploaded => s3://{bucket}/{key}")


print("🚀 Kafka → S3 Consumer Started... Listening for messages...")

# Continuous consumption loop
while True:
    # Structured Topic
    for msg in structured_consumer:
        key = f"structured-{time.time()}.json"
        upload_data_to_s3(BUCKET_STRUCTURED, key, msg.value)
        break

    # Semi-structured Topic
    for msg in semi_consumer:
        key = f"semi-{time.time()}.json"
        upload_data_to_s3(BUCKET_SEMI, key, msg.value)
        break

    # Unstructured Topic
    for msg in unstructured_consumer:
        key = f"unstructured-{time.time()}.json"
        upload_data_to_s3(BUCKET_UNSTRUCTURED, key, msg.value)
        break
