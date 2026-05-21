#!/bin/bash

# Verificar privilegios de root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Se requieren privilegios de root." >&2
    exit 1
fi

# --- LÓGICA DE DETECCIÓN INTELIGENTE ---
# 1. Intentar primero con /run/media/root/
TARGET=$(find /run/media/root/ -maxdepth 2 -name "@" -type d 2>/dev/null | head -n 1)

# 2. Si no se encontró, buscar en el resto de /run/media/
if [ -z "$TARGET" ]; then
    echo "[*] No encontrado en /run/media/root/. Buscando en otras rutas..."
    TARGET=$(find /run/media/ -maxdepth 3 -name "@" -type d 2>/dev/null | head -n 1)
fi

# 3. Validación final
if [ -z "$TARGET" ]; then
    echo "[!] Error: No se pudo encontrar ninguna carpeta '@' en /run/media/."
    exit 1
fi

echo "[*] Target detectado y fijado en: $TARGET"

# Función de limpieza (se ejecuta al salir, incluyendo fallos)
cleanup() {
    if [ -n "$TARGET" ]; then
        echo "[*] Limpiando montajes..."
        for dir in tmp/.X11-unix run sys proc dev/pts dev; do
            umount -l "$TARGET/$dir" 2>/dev/null
        done
    fi
}
trap cleanup EXIT

# --- VERIFICACIÓN DE XHOST ---
if ! command -v xhost >/dev/null 2>&1; then
    echo "[*] Instalando xorg-xhost..."
    pacman -Sy --noconfirm xorg-xhost
fi

# Detectar usuario real
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo "~$REAL_USER")
XAUTH_SOURCE="$REAL_HOME/.Xauthority"

# --- MONTAJES ---
echo "[*] Montando directorios del sistema..."
mount --bind /dev "$TARGET/dev"
mount --bind /dev/pts "$TARGET/dev/pts"
mount --bind /proc "$TARGET/proc"
mount --bind /sys "$TARGET/sys"
mount --bind /run "$TARGET/run"
mount --bind /tmp/.X11-unix "$TARGET/tmp/.X11-unix"

# --- CONFIGURACIÓN X11 ---
xhost + >/dev/null 2>&1
if [ -f "$XAUTH_SOURCE" ]; then
    cp "$XAUTH_SOURCE" "$TARGET/root/.Xauthority"
    chmod 644 "$TARGET/root/.Xauthority"
else
    echo "[!] Advertencia: No se encontró .Xauthority. Las apps gráficas podrían fallar."
fi

# --- ENTRAR AL CHROOT ---
echo "[*] Entrando al sistema..."
echo "[*] DISPLAY activo: $DISPLAY"

chroot "$TARGET" /bin/bash -c "export DISPLAY=$DISPLAY; export XAUTHORITY=/root/.Xauthority; exec /bin/bash"

# El trap se encargará de desmontar todo al cerrar la sesión del chroot
