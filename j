#!/bin/sh

# Copia todo lo de dentro de chroot a la carpeta iso que está fuera de chroot

# El comando entrar tiene que tener esta línea de código.
# mount --bind / /n/iso

destino="./iso/bin"
mkdir -p "$destino"
OLDIFS=$IFS
IFS=':'
for d in $PATH; do
    [ -d "$d" ] && cp -uL "$d"/* "$destino" 2>/dev/null
done
IFS=$OLDIFS
