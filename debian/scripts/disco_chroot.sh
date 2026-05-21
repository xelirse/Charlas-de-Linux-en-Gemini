#!/bin/sh

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="/run/media/root/DISCO/@"

# Función para desmontar de forma segura
desmontar_si_existe() {
    if mountpoint -q "$1"; then
        printf "[!] Intentando desmontar: %s ... " "$1"
        # Usamos 2>/dev/null para ocultar errores si ya no está montado
        umount "$1" 2>/dev/null || umount -l "$1" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "OK"
        else
            echo "FALLIDO"
        fi
    fi
}

echo "[*] Verificando y limpiando montajes previos..."
# Desmontamos manualmente en orden LIFO (Last-In-First-Out)
desmontar_si_existe "$TARGET/sys/firmware/efi/efivars"
desmontar_si_existe "$TARGET/dev/pts"
desmontar_si_existe "$TARGET/dev"
desmontar_si_existe "$TARGET/proc"
desmontar_si_existe "$TARGET/sys"
desmontar_si_existe "$TARGET/run"
desmontar_si_existe "$TARGET"
desmontar_si_existe "$MOUNT_POINT"

# 1. MONTAJE DEL DISCO BASE
echo "[*] Realizando montajes nuevos..."
mkdir -p "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
    echo "[+] Montando raíz del disco: $DEVICE en $MOUNT_POINT"
    mount "$DEVICE" "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "❌ Error fatal: No se pudo montar el dispositivo físico $DEVICE."
        exit 1
    fi
fi

if [ ! -d "$TARGET" ]; then
    echo "❌ Error fatal: El directorio objetivo '$TARGET' no existe."
    exit 1
fi

montar_bind() {
    if ! mountpoint -q "$2"; then
        echo "[+] Montando bind: $1 en $2"
        mkdir -p "$2" 2>/dev/null
        mount --bind "$1" "$2"
    else
        echo "[*] $2 ya está montado, saltando..."
    fi
}

# Montaje del propio chroot
montar_bind "$TARGET" "$TARGET"

# Crear directorios y montar
mkdir -p "$TARGET/proc" "$TARGET/sys" "$TARGET/dev" "$TARGET/dev/pts" "$TARGET/run"
montar_bind "/proc" "$TARGET/proc"
montar_bind "/sys" "$TARGET/sys"
montar_bind "/dev" "$TARGET/dev"
montar_bind "/dev/pts" "$TARGET/dev/pts"
montar_bind "/run" "$TARGET/run"

if [ -d "/sys/firmware/efi/efivars" ]; then
    montar_bind "/sys/firmware/efi/efivars" "$TARGET/sys/firmware/efi/efivars"
fi

# ---------------------------------------------------------------------
# SOLUCIÓN DETECCIÓN GRUB
# ---------------------------------------------------------------------
echo "[+] Sincronizando tabla de montajes (/etc/mtab) para GRUB..."
rm -f "$TARGET/etc/mtab" 2>/dev/null
ln -s /proc/mounts "$TARGET/etc/mtab"

# 2. AUTORIZACIÓN X11
if [ -n "$DISPLAY" ]; then
    if command -v xhost >/dev/null 2>&1; then
        xhost +local:root >/dev/null 2>&1
        echo "[*] Autorización X11 concedida."
    fi
fi

echo "[*] Entrando al chroot..."
# Nota: sh no permite asignar variables antes del comando si este no es un builtin,
# pero chroot es un ejecutable externo, por lo que esto funciona correctamente.
DISPLAY="$DISPLAY" chroot "$TARGET" /bin/bash
