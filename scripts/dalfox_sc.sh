#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

URL=$1
OUTPUT="dalfox_report_$(date +%F_%T).txt"

echo "[*] Запускаем Dalfox для $URL..."

dalfox url "$URL" --output "$OUTPUT" --no-color --follow-redirect --silent

echo "[*] Результат записан в $OUTPUT"
