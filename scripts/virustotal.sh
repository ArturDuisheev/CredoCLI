#!/bin/bash

API_KEY="your_api_key_here"

if [ -z "$1" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE="$1"

echo "[*] Отправляем файл $FILE на VirusTotal..."

RESPONSE=$(curl -s --request POST \
  --url 'https://www.virustotal.com/api/v3/files' \
  --header "x-apikey: $API_KEY" \
  --form "file=@${FILE}")

echo "Ответ сервера:"
echo "$RESPONSE"
