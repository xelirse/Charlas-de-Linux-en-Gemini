#!/bin/bash

# --- CONFIGURACIÓN ---
DEVICE="/dev/sda1"
MOUNT_POINT="/run/media/root/DISCO"
TARGET="$MOUNT_POINT/@"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Se requieren privilegios de root." >&2
    exit 1
fi

# --- LÓGICA DE DETECCIÓN REALISTA ---
# En lugar de usar 'mountpoint', verificamos si el subvolumen '@' existe realmente.
# Si no existe, es porque el disco no está montado.
if [ ! -d "$TARGET" ]; then
    echo "[*] El subvolumen '@' no es visible. Intentando montar $DEVICE en $MOUNT_POINT..."
    mkdir -p "$MOUNT_POINT"
    if ! mount "$DEVICE" "$MOUNT_POINT"; then
        echo "[!] Error: No se pudo montar $DEVICE."
        exit 1
    fi
    
    # Doble verificación: ¿Ahora sí existe?
    if [ ! -d "$TARGET" ]; then
        echo "[!] Error: Se montó $DEVICE pero no se encuentra la carpeta '$TARGET'."
        exit 1
    fi
else
    echo "[*] Disco detectado correctamente en $MOUNT_POINT."
fi

# Función de limpieza (se ejecuta al salir)
cleanup() {
    echo "[*] Limpiando montajes..."
    # Desmontamos en orden inverso
    for dir in tmp/.X11-unix run sys proc dev/pts dev; do
        umount -l "$TARGET/$dir" 2>/dev/null
    done
}
trap cleanup EXIT

# --- MONTAJES DE SISTEMA ---
echo "[*] Montando directorios del sistema..."
declare -A montajes=(
    ["/dev"]="$TARGET/dev"
    ["/dev/pts"]="$TARGET/dev/pts"
    ["/proc"]="$TARGET/proc"
    ["/sys"]="$TARGET/sys"
    ["/run"]="$TARGET/run"
    ["/tmp/.X11-unix"]="$TARGET/tmp/.X11-unix"
)

for src in "${!montajes[@]}"; do
    dest="${montajes[$src]}"
    mkdir -p "$dest"
    mount --bind "$src" "$dest"
done

# --- X11 Y CHROOT ---
xhost + >/dev/null 2>&1
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo "~$REAL_USER")
XAUTH_SOURCE="$REAL_HOME/.Xauthority"

if [ -f "$XAUTH_SOURCE" ]; then
    cp "$XAUTH_SOURCE" "$TARGET/root/.Xauthority"
    chmod 644 "$TARGET/root/.Xauthority"
fi

echo "[*] Entrando al sistema..."
chroot "$TARGET" /bin/bash -c "export DISPLAY=$DISPLAY; export XAUTHORITY=/root/.Xauthority; exec /bin/bash"
