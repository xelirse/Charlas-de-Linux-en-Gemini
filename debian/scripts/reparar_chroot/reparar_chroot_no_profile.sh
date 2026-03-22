#!/bin/sh

echo "Advertencia: Ejecutar con precaución"

LC_ALL=C LANG=C chroot . /usr/bin/bash --noprofile --norc
LC_ALL=C LANG=C chroot . /bin/sh --noprofile --norc
LC_ALL=C LANG=C chroot . /bin/sh

# Desde fuera del chroot, en la raíz del mismo:
cp -vf usr/lib/x86_64-linux-gnu/libc.so.6            usr/lib/libc.so.6
cp -vf usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 usr/lib/ld-linux-x86-64.so.2

# Desde fuera del chroot:
rm -rf usr/lib/locale/*
rm -f usr/lib/gconv/gconv-modules.cache

ls -l usr/bin/sh

file usr/bin/sh
# O si prefieres ver la ruta exacta del linker:
readelf -l usr/bin/sh | grep interpreter

# Crear la carpeta lib64 si no existe
mkdir -p lib64

# Enlazar el cargador dinámico (ajusta la ruta si el tuyo está en x86_64-linux-gnu)
cp -vf usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2

# Por si acaso, asegura el enlace de la shell
cp -vf /usr/bin/sh bin/sh

cd usr
ln -svfr busybox sh
ln -svfr busybox ash
