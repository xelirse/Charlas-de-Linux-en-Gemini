#!/bin/bash

# Copia la carpeta local del disco al pendrive

ln -sv /run/media/manjaro/cfb49c22-87f2-47d9-a25b-310d8d8578af/@ /n
cd /n

origen="./local"
destino="/"

# Usamos find para obtener CUALQUIER archivo o directorio dentro de origen
# -mindepth 1 evita que procese el propio directorio "./local"
find "$origen" -mindepth 1 | while read -r item; do

    # Calculamos la ruta relativa para el destino
    # Ejemplo: si item es ./local/usr/bin/algo, sub_path será usr/bin/algo
    sub_path="${item#$origen/}"
    objetivo="$destino$sub_path"

    if [ -d "$item" ]; then
        # Si es un directorio, lo creamos en el destino
        echo "Creando carpeta: $objetivo"
        mkdir -p "$objetivo"
    else
        # Si es un archivo, lo copiamos con cuidado
        # Usamos -d para que si es un enlace simbólico, copie el enlace y no el archivo real
        # (Esto es vital para no inflar el sistema y mantener la estructura de glibc)
        cp -afv "$item" "$objetivo"
    fi
done

konsole -e "sudo entrar" &disown
