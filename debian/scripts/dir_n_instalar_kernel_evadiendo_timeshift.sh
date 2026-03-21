#!/bin/sh

# 1. Movemos los hooks de configuración del usuario (si hay alguno)
mv /etc/pacman.d/hooks/*.hook /tmp/ 2>/dev/null

# 2. Movemos los hooks del sistema (Aquí es donde se esconde Timeshift el 99% de las veces)
mv /usr/share/libalpm/hooks/*.hook /tmp/ 2>/dev/null

# Instalar kernel usando pacman static
pacman-static -S --overwrite="*" glibc glibc-locales lib32-glibc linux612 linux612-headers linux619 linux619-headers
