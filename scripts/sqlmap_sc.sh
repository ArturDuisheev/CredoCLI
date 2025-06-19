#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

URL=$1
OUTPUT="sqlmap_report_$(date +%F_%T).txt"

echo "[*] Запускаем sqlmap для $URL..."

sqlmap -u "$URL" --batch --risk=3 --level=5 --threads=10 --output-dir=sqlmap_output --flush-session > "$OUTPUT" 2>&1

echo "[*] Результат записан в $OUTPUT"
