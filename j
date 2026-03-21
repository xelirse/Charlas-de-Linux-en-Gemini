#!/bin/sh

destino="./iso/bin"
mkdir -p "$destino"
OLDIFS=$IFS
IFS=':'
for d in $PATH; do
    [ -d "$d" ] && cp -uL "$d"/* "$destino" 2>/dev/null
done
IFS=$OLDIFS
