#!/bin/sh

x="
Comando
apt install sudo

Problema
dpkg-preconfigure: unable to re-open stdin: No such file or directory
Error: Can not write log (Is /dev/pts mounted?) - posix_openpt (2: No such file or directory)
(Reading database ... 7942 files and directories currently installed.)
/proc/ is not mounted, but required for successful operation of systemd-tmpfiles. Please mount /proc/. Alternatively, conside
r using the --root= or --image= switches.
/proc/ is not mounted. This is not a supported mode of operation. Please fix
your invocation environment to mount /proc/ and /sys/ properly. Proceeding anyway.
Your mileage may vary.
"

# Solución

# Cambiar de ruta al punto de montaje
cd /n

# Salir de chroot
# Montar directorios del sistema
mount --bind /dev     /n/dev
mount --bind /proc    /n/proc
mount --bind /sys     /n/sys
mount --bind /run     /n/run
mount --bind /dev/pts /n/dev/pts

# Entrar
manjaro-chroot . bash --login
apt install sudo
