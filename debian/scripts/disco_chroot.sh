#!/bin/sh

TARGET="/run/media/root/DISCO/@"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Se requieren privilegios de root." >&2
    exit 1
fi

# 1. VERIFICACIÓN E INSTALACIÓN DE XHOST
if ! command -v xhost >/dev/null 2>&1; then
    echo "[*] 'xhost' no encontrado. Instalando xorg-xhost automáticamente..."
    # -Sy refresca la base de datos, --noconfirm evita preguntas
    pacman -Sy --noconfirm xorg-xhost
    
    # Verificación final por si falló la instalación
    if ! command -v xhost >/dev/null 2>&1; then
        echo "[!] Error: No se pudo instalar xorg-xhost. Revisa tu conexión a internet."
        exit 1
    fi
fi

# Detectar el usuario real que invocó el script vía sudo
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo "~$REAL_USER")
XAUTH_SOURCE="$REAL_HOME/.Xauthority"

# Limpieza
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -l "$TARGET/$dir" 2>/dev/null
done

# Montajes
mount --bind /dev "$TARGET/dev"
mount --bind /dev/pts "$TARGET/dev/pts"
mount --bind /proc "$TARGET/proc"
mount --bind /sys "$TARGET/sys"
mount --bind /run "$TARGET/run"
mount --bind /tmp/.X11-unix "$TARGET/tmp/.X11-unix"

# AUTORIZACIÓN TOTAL (Ahora garantizado que xhost existe)
xhost + >/dev/null 2>&1

# Copia de seguridad del Xauthority
if [ -f "$XAUTH_SOURCE" ]; then
    cp "$XAUTH_SOURCE" "$TARGET/root/.Xauthority"
    chmod 644 "$TARGET/root/.Xauthority"
    echo "[*] Cookie de X11 copiada desde $XAUTH_SOURCE"
else
    echo "[!] Advertencia: No se encontró .Xauthority en $XAUTH_SOURCE"
fi

echo "[*] Entrando al sistema. DISPLAY detectado: $DISPLAY"
# Pasamos la variable de display al chroot
chroot "$TARGET" /bin/bash -c "export DISPLAY=$DISPLAY; export XAUTHORITY=/root/.Xauthority; /bin/bash"

# Limpieza
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -l "$TARGET/$dir" 2>/dev/null
done
