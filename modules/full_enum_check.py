import subprocess

def enum_check(ip):
    print("[*] Nmap scan...")
    subprocess.run(["nmap", "-sC", "-sV", "-Pn", "-T4", "-oN", "nmap_scan.txt", ip])
    try:
        print("[*] Gobuster (80)...")
        subprocess.run([
            "gobuster", "dir",
            "-u", f"http://{ip}",
            "-w", "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt",
            "-x", "php,txt,html",
            "-t", "50",
            "-o", "gobuster_80.txt"
        ])
    except Exception as e:
        print("Ошибочка: ", e)

    print("[*] FTP check...")
    subprocess.run(["nmap", "-p", "21", "--script", "ftp-anon", ip])

    print("[*] SMB check...")
    subprocess.run(["nmap", "-p", "139,445", "--script", "smb-enum-shares.nse,smb-enum-users.nse", ip])
