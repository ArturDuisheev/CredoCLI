import os
import argparse
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

def interactive_mode():
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
            privesc.run()
        elif choice == "4":
            windows_tools.run_enum()
        elif choice == "5":
            post_exploit.run()
        elif choice == "6":
            ip = input("Target IP: ")
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

def cli_mode(args):
    if args.full_enum:
        full_enum_check.enum_check(args.full_enum)
    elif args.reverse:
        ip, port = args.reverse
        reverse_shells.run(ip=ip, port=port)
    elif args.privesc:
        privesc.menu()
    elif args.windows:
        windows_tools.run_enum()
    elif args.post:
        post_exploit.run()
    elif args.web:
        web_enum.run_minimal(args.web)
    elif args.upload:
        ip, port = args.upload
        auto_upload.full_upload_stack(ip, port)
    else:
        interactive_mode()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="CTF Toolkit by FMCREDO x MegaTeam")
    parser.add_argument("--full-enum", metavar="IP", help="Run Linux full enum on target IP")
    parser.add_argument("--reverse", nargs=2, metavar=("IP", "PORT"), help="Generate reverse shell")
    parser.add_argument("--privesc", action="store_true", help="Launch privilege escalation tools")
    parser.add_argument("--windows", action="store_true", help="Run Windows enumeration")
    parser.add_argument("--post", action="store_true", help="Show post-exploitation tips")
    parser.add_argument("--web", metavar="IP", help="Run web enumeration tools on target IP")
    parser.add_argument("--upload", nargs=2, metavar=("IP", "PORT"), help="Upload file tools (curl/wget + python3 server)")

    args = parser.parse_args()
    cli_mode(args)
