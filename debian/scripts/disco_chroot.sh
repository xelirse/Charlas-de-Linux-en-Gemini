#!/bin/sh

# f_disco_chroot.sh - Entorno Chroot Gráfico Avanzado (Multi-pestaña)
# Rutas: Soporte dinámico para /mnt/mi_disco y /run/media/root/DISCO/@
# Versión: Limpieza forzada directa sin validaciones intermedias

# 1. Validación de privilegios de Root
if [ "$EUID" -ne 0 ]; then
  echo "[-] ERROR: Este script debe ejecutarse como root. Usa: sudo ./f_disco_chroot.sh"
  exit 1
fi

# 2. Autodetección de la ruta objetivo (TARGET_DIR)
RUTA_1="/run/media/root/DISCO/@"
RUTA_2="/mnt/mi_disco"
TARGET_DIR=""

if [ -f "$RUTA_1/bin/bash" ] || [ -f "$RUTA_1/bin/sh" ]; then
    TARGET_DIR="$RUTA_1"
    echo "==> [INFO] Sistema detectado en: $TARGET_DIR"
elif [ -f "$RUTA_2/bin/bash" ] || [ -f "$RUTA_2/bin/sh" ]; then
    TARGET_DIR="$RUTA_2"
    echo "==> [INFO] Sistema detectado en: $TARGET_DIR"
else
    echo "[-] ERROR CRÍTICO: No se encuentra un sistema operativo válido."
    echo "    Se buscaron las siguientes rutas:"
    echo "    - $RUTA_1"
    echo "    - $RUTA_2"
    exit 1
fi

# Elegir la shell disponible en el chroot
if [ -f "$TARGET_DIR/bin/bash" ]; then
    CHROOT_SHELL="/bin/bash"
else
    CHROOT_SHELL="/bin/sh"
fi

# 3. Validar / Instalar 'xhost' en el Manjaro Host
if ! command -v xhost &>/dev/null; then
    echo "[!] 'xhost' no está instalado en el Host. Instalando..."
    pacman -Sy --noconfirm xorg-xhost
fi

echo "==> 1. Autorizando entorno gráfico (X11) en el Host..."
xhost +local:root &>/dev/null

echo "==> 2. Montando sistemas de archivos virtuales (Soporte Multi-pestaña)..."
mkdir -p "$TARGET_DIR"/{dev/pts,proc,sys,run,tmp/.X11-unix,root,etc}

# Montajes directos secuenciales
mount --bind /dev          "$TARGET_DIR/dev"          2>/dev/null
mount --bind /dev/pts      "$TARGET_DIR/dev/pts"      2>/dev/null
mount --bind /proc         "$TARGET_DIR/proc"         2>/dev/null
mount --bind /sys          "$TARGET_DIR/sys"          2>/dev/null
mount --bind /run          "$TARGET_DIR/run"          2>/dev/null
mount --bind /tmp/.X11-unix "$TARGET_DIR/tmp/.X11-unix" 2>/dev/null

# Asegurar DNS públicos
echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > "$TARGET_DIR/etc/resolv.conf"

# Compartir cookies X11
if [ -f "$HOME/.Xauthority" ]; then
    cp "$HOME/.Xauthority" "$TARGET_DIR/root/"
fi

echo "--------------------------------------------------------"
echo "==> [LISTO] Entorno preparado. Entrando al Chroot..."
echo "    Ruta actual: $TARGET_DIR"
echo "    Soporte gráfico y multi-pestaña activos."
echo "    Escribe 'exit' para salir cuando termines."
echo "--------------------------------------------------------"

# Entramos directo a la shell interactiva
chroot "$TARGET_DIR" env DISPLAY="$DISPLAY" HOME=/root LANG=es_AR.UTF-8 "$CHROOT_SHELL"

# ========================================================================
# RUTINA DE LIMPIEZA Y DESMONTAJE AGRESIVA (Al escribir 'exit')
# ========================================================================
echo "==> Saliendo del entorno chroot... Forzando desmontaje completo."

# Función de desmontaje directo e incondicional
force_umount() {
    # Intenta desmontaje limpio, si falla mete lazy unmount (-l) de una
    umount "$1" 2>/dev/null || umount -l "$1" 2>/dev/null
}

# 1. Desmontar los sistemas virtuales internos obligatoriamente en orden inverso
force_umount "$TARGET_DIR/tmp/.X11-unix"
force_umount "$TARGET_DIR/run"
force_umount "$TARGET_DIR/sys"
force_umount "$TARGET_DIR/proc"
force_umount "$TARGET_DIR/dev/pts"
force_umount "$TARGET_DIR/dev"

# 2. Desmontar la partición base del disco
echo "==> Desmontando punto de montaje raíz ($TARGET_DIR)..."
force_umount "$TARGET_DIR"

# Si TARGET_DIR era el subvolumen Btrfs (@), desmontamos también la base si quedó colgada
if [ "$TARGET_DIR" = "$RUTA_1" ]; then
    force_umount "/run/media/root/DISCO"
fi

echo "==> [ÉXITO] Limpieza finalizada. Todo desmontado y disco liberado."
