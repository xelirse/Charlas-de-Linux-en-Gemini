#!/bin/sh

# Creamos una carpeta temporal para esconder los hooks
mkdir -pv /n/etc/pacman.d/hooks_backup

# Movemos los hooks de la carpeta de pacman a la temporal
# Esto evitará que se active Timeshift
mv /n/etc/pacman.d/hooks/* /n/etc/pacman.d/hooks_backup/

# Instalar libc
pacman-static -Syu --overwrite="*" --root /n glibc glibc-locales lib32-glibc
