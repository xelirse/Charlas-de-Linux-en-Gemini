#!/bin/bash

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="/run/media/root/DISCO/@"

# El orden estricto de limpieza: de adentro hacia afuera
PUNTOS_A_LIMPIAR=(
    "$TARGET/sys/firmware/efi/efivars"
    "$TARGET/dev/pts" 
    "$TARGET/dev" 
    "$TARGET/proc" 
    "$TARGET/sys" 
    "$TARGET/run"
    "$TARGET"       # <-- CLAVE: Desmontar el bind del propio chroot
    "$MOUNT_POINT"
)

echo "[*] Verificando y limpiando montajes previos..."
for punto in "${PUNTOS_A_LIMPIAR[@]}"; do
    if mountpoint -q "$punto"; then
        echo -n "[!] Intentando desmontar: $punto ... "
        if umount "$punto" 2>/dev/null || umount -R "$punto" 2>/dev/null || umount -l "$punto" 2>/dev/null; then
            echo "OK"
        else
            echo "FALLIDO (El destino sigue ocupado)"
        fi
    fi
done

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

# Verificar que el directorio raíz de la distribución (@) exista realmente
if [ ! -d "$TARGET" ]; then
    echo "❌ Error fatal: El directorio objetivo '$TARGET' no existe en el disco."
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

# ---------------------------------------------------------------------
# LA PIEZA FALTANTE PARA GRUB: Convertir el directorio en Mountpoint
# ---------------------------------------------------------------------
montar_bind "$TARGET" "$TARGET"

# Crear los directorios virtuales internos
mkdir -p "$TARGET/proc" "$TARGET/sys" "$TARGET/dev" "$TARGET/dev/pts" "$TARGET/run"

# Enlaces directos del núcleo del anfitrión al entorno de destino
montar_bind "/proc" "$TARGET/proc"
montar_bind "/sys" "$TARGET/sys"
montar_bind "/dev" "$TARGET/dev"
montar_bind "/dev/pts" "$TARGET/dev/pts"
montar_bind "/run" "$TARGET/run"

# Extra: Exponer variables EFI si el sistema anfitrión es UEFI 
if [ -d "/sys/firmware/efi/efivars" ]; then
    montar_bind "/sys/firmware/efi/efivars" "$TARGET/sys/firmware/efi/efivars"
fi

# ---------------------------------------------------------------------
# SOLUCIÓN DETECCIÓN GRUB: Sincronizar tabla de dispositivos montados
# ---------------------------------------------------------------------
echo "[+] Sincronizando tabla de montajes (/etc/mtab) para GRUB..."
rm -f "$TARGET/etc/mtab" 2>/dev/null
ln -s /proc/mounts "$TARGET/etc/mtab"

# 2. VERIFICACIÓN E INSTALACIÓN EN EL ANFITRIÓN (Manjaro)
if ! command -v xhost >/dev/null 2>&1 || ! command -v xset >/dev/null 2>&1; then
    echo "[*] xhost o xset no funcionan. Procediendo con pacman..."
    rm -f /var/lib/pacman/db.lck 2>/dev/null
    pacman -S --noconfirm --overwrite="*" xorg-xset xorg-xhost
else
    echo "[*] xhost y xset detectados y operativos."
fi

# 3. AUTORIZACIÓN X11
if [ -n "$DISPLAY" ]; then
    if command -v xhost >/dev/null 2>&1; then
        xhost +local:root >/dev/null 2>&1
        echo "[*] Autorización X11 para root concedida."
    fi
fi

echo "[*] Entrando al chroot..."
echo "---------------------------------------------------------------------"

# Entrar al entorno heredando las variables gráficas completas
DISPLAY=$DISPLAY chroot "$TARGET" /bin/bash
