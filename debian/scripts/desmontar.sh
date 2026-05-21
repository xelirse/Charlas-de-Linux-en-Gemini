#!/bin/sh

umount /run/media/root/DISCO/@
umount /run/media/root/DISCO/@/run
umount /run/media/root/DISCO/@/dev/pts
umount /run/media/root/DISCO/@/dev
umount /run/media/root/DISCO/@/sys
umount /run/media/root/DISCO/@/proc
umount /run/media/root/DISCO

# Definir el punto de montaje
PUNTO_MONTAJE="/run/media/root/DISCO"

echo "--- Iniciando proceso de liberación y desmontaje ---"

# 1. Instalar lsof si no está presente
if ! command -v lsof &> /dev/null; then
    echo "Instalando lsof..."
    sudo pacman -S --noconfirm lsof
fi

# 2. Obtener los PIDs de los procesos que usan el disco
# -t (terse mode) nos da solo los PIDs
# +D busca archivos abiertos dentro del directorio
PIDS=$(lsof +D "$PUNTO_MONTAJE" -t)

if [ -z "$PIDS" ]; then
    echo "No hay procesos bloqueando $PUNTO_MONTAJE."
else
    echo "Procesos encontrados bloqueando el disco: $PIDS"
    echo "Cerrando procesos..."
    kill -9 $PIDS
    sleep 2 # Esperar un momento para que los procesos terminen
fi

# 3. Desmontar
echo "Intentando desmontar $PUNTO_MONTAJE..."
if sudo umount "$PUNTO_MONTAJE"; then
    echo "¡Éxito! El disco ha sido desmontado."
else
    echo "Error: No se pudo desmontar el disco. Revisa si hay procesos persistentes."
fi
