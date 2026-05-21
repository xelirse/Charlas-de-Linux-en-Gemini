#!/bin/sh

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="/run/media/root/DISCO/@"

# --- 1. INSTALACIÓN DE DEPENDENCIAS (HOST) ---
if ! command -v xhost >/dev/null 2>&1; then
    echo "[*] Instalando xorg-xhost con pacman..."
    sudo pacman -S --noconfirm xorg-xhost
fi

# Función para desmontar de forma segura
desmontar_si_existe() {
    if mountpoint -q "$1"; then
        printf "[!] Intentando desmontar: %s ... " "$1"
        umount "$1" 2>/dev/null || umount -l "$1" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "OK"
        else
            echo "FALLIDO"
        fi
    fi
}

echo "[*] Verificando y limpiando montajes previos..."
desmontar_si_existe "$TARGET/sys/firmware/efi/efivars"
desmontar_si_existe "$TARGET/dev/pts"
desmontar_si_existe "$TARGET/dev"
desmontar_si_existe "$TARGET/proc"
desmontar_si_existe "$TARGET/sys"
desmontar_si_existe "$TARGET/run"
desmontar_si_existe "$TARGET"
desmontar_si_existe "$MOUNT_POINT"

# 2. MONTAJE DEL DISCO BASE
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

# 3. REPARACIÓN DE _APT Y PERMISOS
echo "[+] Asegurando permisos para el usuario _apt..."
# Verificar/Crear usuario _apt dentro del chroot
chroot "$TARGET" /bin/sh -c 'if ! getent passwd _apt >/dev/null 2>&1; then groupadd -g 100 _apt; useradd -u 100 -g _apt -d /nonexistent -s /usr/sbin/nologin _apt; fi'

mkdir -p "$TARGET/var/cache/apt/archives/partial"
chown -R _apt:root "$TARGET/var/cache/apt/archives"
chmod 755 "$TARGET/var/cache/apt/archives"
chmod 755 "$TARGET/var/cache/apt/archives/partial"

# Archivos .deb
find "$TARGET" -maxdepth 1 -name "*.deb" -exec chmod 644 {} \;

# 4. SOLUCIÓN DETECCIÓN GRUB
echo "[+] Sincronizando tabla de montajes (/etc/mtab) para GRUB..."
rm -f "$TARGET/etc/mtab" 2>/dev/null
ln -s /proc/mounts "$TARGET/etc/mtab"

# 5. AUTORIZACIÓN X11
if [ -n "$DISPLAY" ]; then
    if command -v xhost >/dev/null 2>&1; then
        xhost +local:root >/dev/null 2>&1
        echo "[*] Autorización X11 concedida."
    fi
    
    # Copiar credenciales XAuthority para root
    if [ -f "$XAUTHORITY" ]; then
        cp "$XAUTHORITY" "$TARGET/root/.Xauthority"
        chroot "$TARGET" chmod 600 /root/.Xauthority
    fi
fi

echo "[*] Entrando al chroot..."
# Mantenemos DISPLAY y XAUTHORITY para aplicaciones gráficas
env DISPLAY="$DISPLAY" XAUTHORITY="/root/.Xauthority" chroot "$TARGET" /bin/bash
