#!/bin/sh

# Creamos una carpeta temporal para esconder los hooks
mkdir -p /etc/pacman.d/hooks_backup

# Movemos los hooks de la carpeta de pacman a la temporal
# Esto evitará que se active Timeshift
mv /etc/pacman.d/hooks/* /n/etc/pacman.d/hooks_backup/

# Instalar libc
pacman-static -Syu --overwrite="*" glibc glibc-locales lib32-glibc
