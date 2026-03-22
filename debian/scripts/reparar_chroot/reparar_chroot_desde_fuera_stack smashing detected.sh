#!/bin/sh

# Remover bloqueo de pacman
rm /var/lib/pacman/db.lck

# El internet
cp -vf etc/resolv.conf /etc/resolv.conf

# Configuración de pacman
cp -vf etc/resolv.conf /etc/pacman.conf

# Para dpkg-deb
pacman -S --overwrite="*" dpkg strace busybox nix-busybox gdb

mkdir -p tmp/libc_rescue
dpkg-deb -x var/cache/apt/archives/libc6_2.42-13_amd64.deb tmp/libc_rescue
cp -rf tmp/libc_rescue/* /n
/usr/sbin/ldconfig
dpkg --configure -a
busybox ls -lh lib/libc.so*
busybox rm -v usr/lib/libc.so.6.broken
busybox rm -v /usr/lib/libc.so.6.broken
busybox rm -v usr/lib/x86_64-linux-gnu/libc.so
busybox rm -v usr/lib/x86_64-linux-gnu/libc.so.6
busybox rm -v usr/lib/x86_64-linux-gnu/libc.so.6.0
busybox rm -v usr/lib/x86_64-linux-gnu/libc.so.6.0.0
busybox ls -lh usr/lib/x86_64-linux-gnu/libc.so.6*
busybox cp -vf lib/libc.* usr/lib/x86_64-linux-gnu
