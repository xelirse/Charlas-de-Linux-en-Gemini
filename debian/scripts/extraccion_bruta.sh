#!/bin/sh

# Busca el .deb en la caché de apt
cd /var/cache/apt/archives/
ar x systemd_260-1_amd64.deb
tar -xvf data.tar.xz -C /
# Ahora intenta configurar de nuevo
dpkg --configure -a
