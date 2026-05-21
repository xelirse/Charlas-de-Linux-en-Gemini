#!/bin/sh

# ========================================================================
# f_disco_chroot.sh - Entorno Chroot Gráfico Avanzado (Multi-pestaña)
# Ruta objetivo: Subvolumen Btrfs (@) en disco externo Manjaro
# Versión Limpia: Solo montajes nativos y soporte de ventanas X11
# ========================================================================

# --- CONFIGURACIÓN ---
TARGET_DIR="/run/media/root/DISCO/@"
# ---------------------

# 1. Validación de privilegios de Root
if [ "$EUID" -ne 0 ]; then
  echo "[-] ERROR: Este script debe ejecutarse como root. Usa: sudo ./f_disco_chroot.sh"
  exit 1
fi

# 2. Validar si el subvolumen Btrfs está realmente disponible y montado
if [ ! -f "$TARGET_DIR/bin/bash" ] && [ ! -f "$TARGET_DIR/bin/sh" ]; then
    echo "[-] ERROR CRÍTICO: No se encuentra un sistema operativo válido en '$TARGET_DIR'."
    echo "    ¿El disco está desconectado o se desmontó el subvolumen '@'?"
    exit 1
fi

# Elegir la shell disponible en el chroot (prioriza bash)
if [ -f "$TARGET_DIR/bin/bash" ]; then
    CHROOT_SHELL="/bin/bash"
else
    CHROOT_SHELL="/bin/sh"
fi

# 3. Validar / Instalar 'xhost' en el Manjaro Host si hiciera falta
if ! command -v xhost &>/dev/null; then
    echo "[!] 'xhost' no está instalado en el Host. Instalando..."
    pacman -Sy --noconfirm xorg-xhost
fi

echo "==> 1. Autorizando entorno gráfico (X11) en el Host..."
xhost +local:root &>/dev/null

echo "==> 2. Montando sistemas de archivos virtuales (Soporte Multi-pestaña)..."
mkdir -p "$TARGET_DIR"/{dev/pts,proc,sys,run,tmp/.X11-unix,root,etc}

# Función para evitar errores si relanzas el script sin haber desmontado antes
safe_mount() {
    if ! mountpoint -q "$2"; then
        mount --bind "$1" "$2"
    fi
}

safe_mount /dev          "$TARGET_DIR/dev"
safe_mount /dev/pts      "$TARGET_DIR/dev/pts"
safe_mount /proc         "$TARGET_DIR/proc"
safe_mount /sys          "$TARGET_DIR/sys"
safe_mount /run          "$TARGET_DIR/run"
safe_mount /tmp/.X11-unix "$TARGET_DIR/tmp/.X11-unix"

# Asegurar DNS públicos reales por si necesitas usar pacman dentro del chroot
echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > "$TARGET_DIR/etc/resolv.conf"

# Compartir cookies de autorización X11 para heredar accesos de ventanas
if [ -f "$HOME/.Xauthority" ]; then
    cp "$HOME/.Xauthority" "$TARGET_DIR/root/"
fi

echo "--------------------------------------------------------"
echo "==> [LISTO] Entorno preparado. Entrando al Chroot..."
echo "    Soporte gráfico y multi-pestaña activos en subvolumen @."
echo "    Escribe 'exit' para salir cuando termines."
echo "--------------------------------------------------------"

# Entramos directo a la shell interactiva inyectando las variables de entorno
chroot "$TARGET_DIR" env DISPLAY="$DISPLAY" HOME=/root LANG=es_AR.UTF-8 "$CHROOT_SHELL"

echo "==> Saliendo del entorno chroot de forma segura."
