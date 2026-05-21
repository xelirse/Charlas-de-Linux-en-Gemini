#!/bin/sh

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="/run/media/root/DISCO/@"

# Lista de puntos a limpiar en orden inverso
PUNTOS_A_LIMPIAR=("$TARGET/dev/pts" "$TARGET/dev" "$TARGET/sys" "$TARGET/proc" "$MOUNT_POINT")

echo "[*] Verificando y limpiando montajes previos..."

for punto in "${PUNTOS_A_LIMPIAR[@]}"; do
    # Verificamos si realmente está montado antes de intentar
    if mountpoint -q "$punto"; then
        echo -n "[!] Intentando desmontar: $punto ... "
        # Intentamos desmontar y capturamos el resultado
        if umount "$punto"; then
            echo "OK"
        else
            echo "FALLIDO (El destino está ocupado o en uso)"
        fi
    fi
done

# 2. MONTAJES
echo "[*] Realizando montajes nuevos..."

mkdir -p "$MOUNT_POINT"
if ! mountpoint -q "$MOUNT_POINT"; then
    mount "$DEVICE" "$MOUNT_POINT" || { echo "Error: No se pudo montar $DEVICE"; exit 1; }
fi

# Función para montar bind solo si no existe
montar_bind() {
    if ! mountpoint -q "$2"; then
        echo "[+] Montando bind: $1 en $2"
        mount --bind "$1" "$2"
    else
        echo "[*] $2 ya está montado, saltando..."
    fi
}

montar_bind "/proc" "$TARGET/proc"
montar_bind "/sys" "$TARGET/sys"
montar_bind "/dev" "$TARGET/dev"
montar_bind "/dev/pts" "$TARGET/dev/pts"

echo "[*] Entrando al chroot..."
chroot "$TARGET" /bin/bash
