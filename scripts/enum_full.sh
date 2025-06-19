#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <target_ip_or_domain>"
  exit 1
fi

TARGET=$1
OUTPUT="nmap_scan_${TARGET}_$(date +%F_%T).txt"

echo "[*] Запуск nmap скана на $TARGET..."

nmap -sC -sV -O -p- --min-rate=1000 --open -oN "$OUTPUT" "$TARGET"

echo "[*] Результат сохранён в $OUTPUT"
