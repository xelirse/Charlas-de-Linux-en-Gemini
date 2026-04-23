#!/bin/sh

# 1. Capturamos todos los archivos que ldconfig reporta como "no es un enlace simbólico"
bad_files=$(sudo ldconfig 2>&1 | grep "no es un enlace simbólico" | awk '{print $2}')

for file in $bad_files; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        echo "Reparando: $file"
        # Borramos el archivo físico "falso"
        sudo rm "$file"
    fi
done

# 2. Ahora que los obstáculos no están, ldconfig creará los links correctos
ldconfig
