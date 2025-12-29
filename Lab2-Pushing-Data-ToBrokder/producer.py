from kafka import KafkaProducer
import os
import csv
import json
import base64

BASE_DIR = "/home/ubuntu/generated_data"

producer = KafkaProducer(
    bootstrap_servers=["172.31.27.216:19092"],
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

# Structured: CSV -> JSON
def send_structured():
    folder = os.path.join(BASE_DIR, "structured")
    for file in os.listdir(folder):
        file_path = os.path.join(folder, file)
        if not file_path.endswith(".csv"):
            continue
        with open(file_path, "r") as f:
            reader = csv.DictReader(f)
            for row in reader:
                row["source"] = file
                producer.send("structured-topic", row)
    print("Structured data sent ✔")

# Semi-Structured: JSON Lines or Raw Logs
def send_semi():
    folder = os.path.join(BASE_DIR, "semi_structured")
    for file in os.listdir(folder):
        file_path = os.path.join(folder, file)
        if not file_path.endswith(".json"):
            continue
        with open(file_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                except:
                    data = {"raw": line}
                data["source"] = file
                producer.send("semi-structured-topic", data)
    print("Semi-structured data sent ✔")

# Unstructured: Treat as log text
def send_unstructured():
    folder = os.path.join(BASE_DIR, "unstructured")
    for file in os.listdir(folder):
        file_path = os.path.join(folder, file)
        with open(file_path, "r") as f:
            for line in f:
                if line.strip():
                    producer.send("unstructured-topic",
                                  {"file": file, "log": line.strip()})
    print("Unstructured log data sent ✔")

send_structured()
send_semi()
send_unstructured()

producer.flush()
print("🎯 All 3 DATASETs sent to Kafka successfully! 🚀")
