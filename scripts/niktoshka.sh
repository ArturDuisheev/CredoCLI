#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <url_or_ip>"
  exit 1
fi

TARGET=$1
OUTPUT="nikto_report_$(date +%F_%T).txt"

echo "[*] Запускаем Nikto на $TARGET..."

nikto -host "$TARGET" -output "$OUTPUT" -nointeractive

echo "[*] Результат записан в $OUTPUT"
