import subprocess

def run_cmd(cmd, output_file=None):
    print(f"\n>>> Выполняем: {cmd}")
    try:
        # Выполняем команду с кодировкой консоли Windows (OEM, cp866)
        completed = subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding='cp866', errors='replace')

        output = completed.stdout
        error = completed.stderr

        if completed.returncode == 0:
            print(output)
        else:
            print(f"Команда завершилась с ошибкой (код {completed.returncode}):\n{error}")

        if output_file:
            with open(output_file, 'a', encoding='utf-8-sig') as f:
                f.write(f"\n>>> Команда: {cmd}\n")
                f.write(output)
                if error:
                    f.write(f"\n>>> Ошибки:\n{error}\n")
                f.write("\n" + ("-"*50) + "\n")

        return completed.returncode
    except Exception as e:
        print(f"Ошибка при выполнении команды: {e}")
        return -1


def download_and_run_sherlock(output_file=None):
    print("\n>>> Скачиваем Sherlock.ps1...")
    download_cmd = (
        "powershell -NoProfile -ExecutionPolicy Bypass -Command "
        "[Console]::OutputEncoding = [Text.UTF8Encoding]::new(); "
        "Invoke-WebRequest -Uri "
        "'https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1' "
        "-OutFile Sherlock.ps1"
    )
    run_cmd(download_cmd, output_file=output_file)

    print("\n>>> Запускаем Sherlock.ps1...")
    run_sherlock_cmd = (
        "powershell -NoProfile -ExecutionPolicy Bypass -Command "
        "[Console]::OutputEncoding = [Text.UTF8Encoding]::new(); "
        "& './Sherlock.ps1'; Find-AllVulns"
    )
    run_cmd(run_sherlock_cmd, output_file=output_file)


def main():
    output_file = "windows_enum_output.txt"

    commands = [
        "hostname",
        "whoami",
        "whoami /groups",
        "net users",
        "netstat -ano",
        "tasklist /v",
        "schtasks /query /fo LIST /v",
        r'reg query "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"'
    ]

    # Очищаем файл перед запуском
    with open(output_file, 'w', encoding='utf-8-sig') as f:
        f.write("Отчет о выполнении команд\n")
        f.write("="*50 + "\n")

    for cmd in commands:
        run_cmd(cmd, output_file=output_file)

    download_and_run_sherlock(output_file)

if __name__ == "__main__":
    main()
