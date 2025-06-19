#!/bin/bash

# === CTF TOOLKIT - главное меню + автоустановка + Telegram отчёт ===

# Настройки Telegram бота — замени на свои
TG_BOT_TOKEN="7774316859:AAEQ0jt5vqdyh-rwcpfTF9Htqx_8IKfGkNo"
TG_CHAT_ID="-1002471466975"

function banner() {
  clear
  echo "╔════════════════════════════════════════════╗"
  echo "║                                            ║"
  echo "║      🔥 FMCREDO x MegaTeam PRESENT 🔥      ║"
  echo "║                                            ║"
  echo "║          CTF TOOLKIT - Главное меню        ║"
  echo "║                                            ║"
  echo "╚════════════════════════════════════════════╝"
  echo
}

function send_telegram() {
  local file=$1
  if [[ -z "$TG_BOT_TOKEN" || -z "$TG_CHAT_ID" ]]; then
    echo "[Telegram] Токен или Chat ID не заданы, пропускаем отправку."
    return
  fi
  if [[ ! -f "$file" ]]; then
    echo "[Telegram] Файл $file не найден, пропускаем отправку."
    return
  fi
  echo "[Telegram] Отправка $file в Telegram..."
  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument" \
    -F chat_id="$TG_CHAT_ID" \
    -F document=@"$file" > /dev/null
  echo "[Telegram] Отправлено."
}

function check_install() {
  local tool=$1
  local install_cmd=$2
  if ! command -v "$tool" &> /dev/null; then
    echo "[*] Инструмент $tool не найден. Устанавливаем..."
    if command -v apt &> /dev/null; then
      sudo apt update && sudo apt install -y $install_cmd
    elif command -v yum &> /dev/null; then
      sudo yum install -y $install_cmd
    else
      echo "Неизвестный пакетный менеджер. Установи $tool вручную."
      exit 1
    fi
  else
    echo "[*] Инструмент $tool уже установлен."
  fi
}

function nmap_scan() {
  check_install nmap nmap
  echo "Введите IP или домен для скана:"
  read target
  local dir="reports/nmap"
  mkdir -p "$dir"
  output="${dir}/nmap_scan_${target}_$(date +%F_%T).txt"
  nmap -sC -sV -O -p- --min-rate=1000 --open -oN "$output" "$target"
  echo "Результат в $output"
  send_telegram "$output"
}

function linpeas_scan() {
  local dir="reports/linpeas"
  mkdir -p "$dir"
  echo "Проверяем linpeas.sh..."
  if [[ ! -f linpeas.sh ]]; then
    wget -q https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O linpeas.sh
    chmod +x linpeas.sh
  fi
  output="${dir}/linpeas_output_$(date +%F_%T).log"
  ./linpeas.sh | tee "$output"
  send_telegram "$output"
}

function dalfox_scan() {
  check_install dalfox dalfox
  echo "Введите URL для сканирования Dalfox:"
  read url
  local dir="reports/dalfox"
  mkdir -p "$dir"
  output="${dir}/dalfox_report_$(date +%F_%T).txt"
  dalfox url "$url" --output "$output" --no-color --follow-redirect --silent
  echo "Результат в $output"
  send_telegram "$output"
}

function sqlmap_scan() {
  check_install sqlmap sqlmap
  echo "Введите URL для сканирования sqlmap:"
  read url
  local dir="reports/sqlmap"
  mkdir -p "$dir"
  output="${dir}/sqlmap_report_$(date +%F_%T).txt"
  sqlmap -u "$url" --batch --risk=3 --level=5 --threads=10 --output-dir=sqlmap_output --flush-session > "$output" 2>&1
  echo "Результат в $output"
  send_telegram "$output"
}

function nikto_scan() {
  check_install nikto nikto
  echo "Введите URL или IP для сканирования Nikto:"
  read target
  local dir="reports/nikto"
  mkdir -p "$dir"
  output="${dir}/nikto_report_$(date +%F_%T).txt"
  nikto -host "$target" -output "$output" -nointeractive
  echo "Результат в $output"
  send_telegram "$output"
}

function virustotal_check() {
  check_install curl curl
  echo "Введите путь к файлу для проверки в VirusTotal:"
  read file
  if [[ ! -f "$file" ]]; then
    echo "Файл не найден."
    return
  fi
  echo "Введите API ключ VirusTotal (https://www.virustotal.com/):"
  read -s apikey
  local dir="reports/virustotal"
  mkdir -p "$dir"
  local outfile="${dir}/virustotal_response_$(date +%F_%T).json"
  echo "Отправляем файл $file на VirusTotal..."
  response=$(curl -s --request POST \
    --url 'https://www.virustotal.com/api/v3/files' \
    --header "x-apikey: $apikey" \
    --form "file=@${file}")
  echo "$response" | tee "$outfile"
  send_telegram "$outfile"
}

function pspy_run() {
  local dir="reports/pspy"
  mkdir -p "$dir"
  echo "Скачиваем pspy64..."
  wget -q https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 -O pspy64
  chmod +x pspy64
  local output="${dir}/pspy64_log_$(date +%F_%T).txt"
  echo "Запускаем pspy64 (60 секунд)..."
  timeout 60s ./pspy64 | tee "$output"
  send_telegram "$output"
}

function die_scan() {
  check_install die die
  echo "Введите путь к файлу для анализа Detect It Easy:"
  read file
  if [[ ! -f "$file" ]]; then
    echo "Файл не найден."
    return
  fi
  die "$file"
}

function cyberchef_run() {
  if ! command -v docker &> /dev/null; then
    echo "[*] Docker не найден, устанавливать CyberChef не получится."
    return
  fi

  if docker ps --filter "name=cyberchef" --format '{{.Names}}' | grep -q cyberchef; then
    echo "CyberChef уже запущен на http://localhost:9090"
  else
    echo "Запускаем CyberChef на http://localhost:9090 ..."
    docker run -d -p 9090:8080 --name cyberchef gchq/cyberchef
    sleep 3
  fi

  echo "Открой в браузере: http://localhost:9090"
}

function iconv_convert() {
  echo "Введите путь к исходному файлу:"
  read input_file
  if [[ ! -f "$input_file" ]]; then
    echo "Файл не найден."
    return
  fi

  echo "Введите исходную кодировку (например, windows-1251):"
  read from_enc

  echo "Введите целевую кодировку (например, UTF-8):"
  read to_enc

  local dir="reports/iconv"
  mkdir -p "$dir"
  output_file="${dir}/${input_file%.*}_converted.${input_file##*.}"

  iconv -f "$from_enc" -t "$to_enc" "$input_file" -o "$output_file"

  if [[ $? -eq 0 ]]; then
    echo "Файл успешно конвертирован: $output_file"
  else
    echo "Ошибка при конвертации."
  fi
}

function hydra_attack() {
  check_install hydra hydra
  echo "Введите цель (IP или домен):"
  read target
  echo "Введите протокол (ssh, ftp, http-get, http-post-form, smb и т.д.):"
  read protocol
  echo "Введите имя пользователя (или путь к файлу со списком пользователей):"
  read user
  echo "Введите путь к словарю паролей:"
  read passlist

  local dir="reports/hydra"
  mkdir -p "$dir"

  if [[ -f "$user" ]]; then
    user_option="-L $user"
  else
    user_option="-l $user"
  fi

  output="${dir}/hydra_${protocol}_${target}_$(date +%F_%T).txt"
  echo "[*] Запускаем Hydra на $protocol с целью $target"
  hydra $user_option -P "$passlist" -f -o "$output" "$target" "$protocol"

  echo "Результаты в файле $output"
  send_telegram "$output"
}

function menu() {
  while true; do
    clear
    banner
    echo "=== CTF TOOLKIT MENU ==="
    echo "1) Nmap - быстрый и глубокий скан"
    echo "2) linPEAS - privesc enumeration"
    echo "3) Dalfox - скан XSS"
    echo "4) sqlmap - скан SQLi"
    echo "5) Nikto - скан уязвимостей веб-сервера"
    echo "6) VirusTotal - проверка файла"
    echo "7) pspy64 - мониторинг процессов"
    echo "8) Detect It Easy (die) - анализ бинарников"
    echo "9) CyberChef - запустить локальный сервис"
    echo "10) iconv - конвертация кодировок файлов"
    echo "11) Hydra - перебор паролей"
    echo "0) Выход"
    echo
    read -p "Выбери действие: " choice

    case $choice in
      1) nmap_scan ;;
      2) linpeas_scan ;;
      3) dalfox_scan ;;
      4) sqlmap_scan ;;
      5) nikto_scan ;;
      6) virustotal_check ;;
      7) pspy_run ;;
      8) die_scan ;;
      9) cyberchef_run ;;
      10) iconv_convert ;;
      11) hydra_attack ;;
      0) echo "Выход..."; exit 0 ;;
      *) echo "Неверный выбор, попробуй снова."; sleep 2 ;;
    esac

    echo "Нажми Enter для продолжения..."
    read
  done
}

# Создаем папку для отчетов, если не существует
mkdir -p reports

# Запуск меню
menu
