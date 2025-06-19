#!/bin/bash

PSPY_URL="https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64"
OUTFILE="pspy64"
LOGFILE="pspy64_log_$(date +%F_%T).txt"

if [[ ! -f "$OUTFILE" ]]; then
  echo "[*] Скачиваем pspy64..."
  wget -q "$PSPY_URL" -O "$OUTFILE" || { echo "Ошибка скачивания pspy64"; exit 1; }
  chmod +x "$OUTFILE"
fi

echo "[*] Запускаем pspy64 (60 секунд мониторинга)..."
timeout 60s ./"$OUTFILE" | tee "$LOGFILE"

echo "[*] Логи мониторинга в $LOGFILE"
