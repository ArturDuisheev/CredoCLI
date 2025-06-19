#!/bin/bash

if ! command -v wireshark &> /dev/null; then
  echo "Wireshark не установлен."
  exit 1
fi

echo "[*] Запуск Wireshark..."
sudo wireshark
