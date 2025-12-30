#!/bin/bash

# ================================
# CONFIGURATION
# ================================
BASE_DIR="./generated_data"
STRUCTURED_DIR="$BASE_DIR/structured"
SEMI_STRUCTURED_DIR="$BASE_DIR/semi_structured"
UNSTRUCTURED_DIR="$BASE_DIR/unstructured"

STRUCTURED_FILE="$STRUCTURED_DIR/data.csv"
SEMI_STRUCTURED_FILE="$SEMI_STRUCTURED_DIR/data.json"
UNSTRUCTURED_FILE="$UNSTRUCTURED_DIR/data.log"

# Create directories
mkdir -p "$STRUCTURED_DIR" "$SEMI_STRUCTURED_DIR" "$UNSTRUCTURED_DIR"

# Create CSV header if not exists
if [ ! -f "$STRUCTURED_FILE" ]; then
  echo "id,timestamp,user,action,value" > "$STRUCTURED_FILE"
fi

echo "🚀 Data generation started (Ctrl+C to stop)..."

ID=1

# ================================
# LOOP – GENERATE DATA EVERY SECOND
# ================================
while true
do
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  EPOCH=$(date +%s)

  USER="user$((RANDOM % 100))"
  ACTIONS=("login" "logout" "purchase" "click" "view")
  ACTION=${ACTIONS[$RANDOM % ${#ACTIONS[@]}]}
  VALUE=$((RANDOM % 1000))

  # ----------------------------
  # 1. STRUCTURED DATA (CSV)
  # ----------------------------
  echo "$ID,$TIMESTAMP,$USER,$ACTION,$VALUE" >> "$STRUCTURED_FILE"

  # ----------------------------
  # 2. SEMI-STRUCTURED DATA (JSON)
  # ----------------------------
  cat <<EOF >> "$SEMI_STRUCTURED_FILE"
{
  "id": $ID,
  "timestamp": "$TIMESTAMP",
  "epoch": $EPOCH,
  "user": "$USER",
  "event": {
    "type": "$ACTION",
    "value": $VALUE
  }
}
EOF

  # ----------------------------
  # 3. UNSTRUCTURED DATA (TEXT)
  # ----------------------------
  echo "[$TIMESTAMP] User=$USER performed action '$ACTION' with value $VALUE" >> "$UNSTRUCTURED_FILE"

  ID=$((ID + 1))
  sleep 1
done
