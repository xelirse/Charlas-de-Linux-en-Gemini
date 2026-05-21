#!/bin/sh

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="/run/media/root/DISCO/@"
PUNTOS_A_LIMPIAR=("$TARGET/dev/pts" "$TARGET/dev" "$TARGET/sys" "$TARGET/proc" "$MOUNT_POINT")

echo "[*] Verificando y limpiando montajes previos..."
for punto in "${PUNTOS_A_LIMPIAR[@]}"; do
    if mountpoint -q "$punto"; then
        echo -n "[!] Intentando desmontar: $punto ... "
        if umount "$punto" 2>/dev/null || umount -l "$punto" 2>/dev/null; then
            echo "OK"
        else
            echo "FALLIDO (El destino sigue ocupado)"
        fi
    fi
done

# 1. MONTAJES
echo "[*] Realizando montajes nuevos..."
mkdir -p "$MOUNT_POINT"
if ! mountpoint -q "$MOUNT_POINT"; then
    mount "$DEVICE" "$MOUNT_POINT" || { echo "Error: No se pudo montar $DEVICE"; exit 1; }
fi

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

# 2. INSTALACIÓN POR FUERA (Anfitrión Arch -> Destino Debian)
# Usamos el pacman de Arch para instalar en la ruta $TARGET
# --dbpath es necesario para usar la base de datos de tu Arch anfitrión
echo "[*] Instalando xorg-xset y xorg-xhost en el destino..."
pacman -S --root "$TARGET" --dbpath /var/lib/pacman --noconfirm xorg-xset xorg-xhost

# 3. AUTORIZACIÓN X11
if [ -n "$DISPLAY" ]; then
    xhost +local:root >/dev/null 2>&1
    echo "[*] Autorización X11 para root concedida."
fi

echo "[*] Entrando al chroot..."
# Mantenemos el DISPLAY para que el entorno gráfico sepa dónde dibujar
DISPLAY=$DISPLAY chroot "$TARGET" /bin/bash
