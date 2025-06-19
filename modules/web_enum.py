import os
import subprocess
import shutil
from datetime import datetime
import requests

# Настройки Telegram бота — замени на свои
TG_BOT_TOKEN = "7774316859:AAEQ0jt5vqdyh-rwcpfTF9Htqx_8IKfGkNo"
TG_CHAT_ID = "860389338"

def send_to_telegram(text):
    url = f"https://api.telegram.org/bot{TG_BOT_TOKEN}/sendMessage"
    data = {
        "chat_id": TG_CHAT_ID,
        "text": text,
    }
    response = requests.post(url, data=data, verify=False)
    if not response.ok:
        print(f"[!] Ошибка отправки в Telegram: {response.text}")

def run_cmd(command, output_file):
    with open(output_file, "w") as f:
        try:
            subprocess.run(command, shell=True, stdout=f, stderr=subprocess.STDOUT)
        except Exception as e:
            print(f"[!] Ошибка при выполнении команды: {e}")

def run_minimal(target):
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    out_dir = f"web_enum_results/{target}_{timestamp}"
    os.makedirs(out_dir, exist_ok=True)

    # WhatWeb
    whatweb_file = os.path.join(out_dir, "whatweb.txt")
    run_cmd(f"whatweb {target}", whatweb_file)

    # Nmap
    nmap_file = os.path.join(out_dir, "nmap_http.txt")
    run_cmd(f"nmap -sV -p 80,443 --script=http-enum,http-title,http-methods -oN {nmap_file} {target}", nmap_file)

    # Nikto
    nikto_file = os.path.join(out_dir, "nikto.txt")
    run_cmd(f"nikto -h {target}", nikto_file)

    # HTTPX
    httpx_file = os.path.join(out_dir, "httpx.txt")
    httpx_path = shutil.which("httpx")
    if httpx_path:
        run_cmd(f"echo {target} | httpx -title -status-code -tech-detect", httpx_file)
    else:
        httpx_file = None
        print("[!] httpx не найден, пропускаем...")

    # Gobuster
    gobuster_file = os.path.join(out_dir, "gobuster_http.txt")
    wordlist = "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
    if os.path.exists(wordlist):
        run_cmd(f"gobuster dir -u http://{target} -w {wordlist} -t 30 -o {gobuster_file}", gobuster_file)
    else:
        gobuster_file = None
        print(f"[!] Wordlist не найден: {wordlist}, пропускаем Gobuster.")

    def read_file(path):
        if path and os.path.exists(path):
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                return f.read()
        return ""

    report = f"*Результаты Web Enum для {target}*\n\n"
    report += "*WhatWeb:*\n" + (read_file(whatweb_file)[:1500] or "Пустой результат") + "\n\n"
    report += "*Nmap:*\n" + (read_file(nmap_file)[:1500] or "Пустой результат") + "\n\n"
    report += "*Nikto:*\n" + (read_file(nikto_file)[:1500] or "Пустой результат") + "\n\n"

    if httpx_file:
        report += "*HTTPX:*\n" + (read_file(httpx_file)[:1500] or "Пустой результат") + "\n\n"
    if gobuster_file:
        report += "*Gobuster:*\n" + (read_file(gobuster_file)[:1500] or "Пустой результат") + "\n\n"

    send_to_telegram(report)
    print("[✔] Отчет отправлен в Telegram.")
