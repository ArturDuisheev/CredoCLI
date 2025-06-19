#!/bin/bash

LINPEAS_URL="https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"
OUTFILE="linpeas.sh"
LOGFILE="linpeas_output_$(date +%F_%T).log"

echo "[*] Проверяем наличие linpeas.sh..."

if [[ ! -f "$OUTFILE" ]]; then
  echo "[*] Скачиваем linpeas.sh..."
  wget -q "$LINPEAS_URL" -O "$OUTFILE" || { echo "Ошибка скачивания linpeas"; exit 1; }
  chmod +x "$OUTFILE"
fi

echo "[*] Запускаем linpeas.sh..."

./"$OUTFILE" | tee "$LOGFILE"

echo "[*] Результат записан в $LOGFILE"
