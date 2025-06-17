import os
from modules import (
    full_enum_check,
    reverse_shells,
    privesc,
    windows_tools,
    post_exploit,
    web_enum,
    auto_upload,
)

def banner():
    print("""
   _______ _______ _______         
  |       |   _   |   _   |        
  |  |--  |       |       |  CTF TOOLKIT
  |_______|___|___|___|___|  by FMCREDO x MegaTeam
    """)

def menu():
    banner()
    print("""
[1] Full Enum (Linux)
[2] Generate Reverse Shell
[3] Privesc Tools (SUID, LinPEAS, etc)
[4] Windows Enum
[5] Post-Exploitation Tips
[6] Web Enum (nikto, nuclei, wafw00f)
[7] Upload File (curl/wget + python server)
[0] Exit
    """)
    return input("Select an option: ")

def main():
    while True:
        choice = menu()
        if choice == "1":
            ip = input("Target IP: ")
            full_enum_check.enum_check(ip)
        elif choice == "2":
            ip = input("reverse IP: ")
            port = input("Port: ")
            reverse_shells.run(ip=ip, port=port)
        elif choice == "3":
            privesc.menu()
        elif choice == "4":
            windows_tools.run_enum()
        elif choice == "5":
            post_exploit.run()
        elif choice == "6":
            ip = input("Target IP: ")
            # Вызываем упрощенный веб-энум с отправкой в Telegram
            web_enum.run_minimal(ip)
        elif choice == "7":
            ip = input("Your Attacker IP: ")
            port = input("Port: ")
            auto_upload.full_upload_stack(ip, port)
        elif choice == "0":
            print("[-] Exiting. Good hunting!")
            break
        else:
            print("[!] Invalid choice.")

if __name__ == "__main__":
    main()
