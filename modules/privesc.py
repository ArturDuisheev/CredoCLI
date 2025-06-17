import subprocess

def run():
    print("\n[+] SUID binaries:")
    subprocess.run(["find", "/", "-perm", "-4000", "-type", "f"], stderr=subprocess.DEVNULL)

    print("\n[+] Sudo permissions:")
    subprocess.run(["sudo", "-l"])

    print("\n[+] Capabilities:")
    subprocess.run(["getcap", "-r", "/"], stderr=subprocess.DEVNULL)
