#!/bin/bash
# ========================================================================
# f_disco_chroot.sh - Entorno Chroot con Instalación Automática
# ========================================================================

if [ "$EUID" -ne 0 ]; then
  echo "[-] ERROR: Este script debe ejecutarse como root."
  exit 1
fi

TARGET_DIR="/run/media/manjaro/DISCO/@"

# 1. Asegurar que xhost esté instalado en el Host
if ! command -v xhost &>/dev/null; then
    echo "[!] 'xhost' no encontrado. Instalando xorg-xhost..."
    pacman -Sy --noconfirm xorg-xhost
fi

# 2. Limpieza de residuos previos
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -l "$TARGET_DIR/$dir" 2>/dev/null
done

# 3. Validación de sistema
if [ ! -f "$TARGET_DIR/usr/bin/bash" ]; then
    echo "[-] ERROR: Sistema operativo no encontrado en $TARGET_DIR"
    exit 1
fi

# 4. Autorización gráfica
xhost +local:root &>/dev/null

# 5. Montaje de entornos
mkdir -p "$TARGET_DIR"/{dev/pts,proc,sys,run,tmp/.X11-unix,root,etc}

mount --bind /dev          "$TARGET_DIR/dev"          && mount --make-private "$TARGET_DIR/dev"
mount --bind /dev/pts      "$TARGET_DIR/dev/pts"      && mount --make-private "$TARGET_DIR/dev/pts"
mount --bind /proc         "$TARGET_DIR/proc"         && mount --make-private "$TARGET_DIR/proc"
mount --bind /sys          "$TARGET_DIR/sys"          && mount --make-private "$TARGET_DIR/sys"
mount --bind /run          "$TARGET_DIR/run"          && mount --make-private "$TARGET_DIR/run"
mount --bind /tmp/.X11-unix "$TARGET_DIR/tmp/.X11-unix" && mount --make-private "$TARGET_DIR/tmp/.X11-unix"

echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > "$TARGET_DIR/etc/resolv.conf"
[ -f "$HOME/.Xauthority" ] && cp "$HOME/.Xauthority" "$TARGET_DIR/root/"

# 6. Entrada al Chroot inyectando display y autorización
echo "==> [CHROOT ACTIVO] Escribe 'exit' para salir."
chroot "$TARGET_DIR" /bin/bash -c "
    export DISPLAY=$DISPLAY
    export XAUTHORITY=/root/.Xauthority
    export QT_X11_NO_MITSHM=1
    exec /usr/bin/bash
"

# 7. Limpieza al salir
echo "==> Limpiando..."
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -f "$TARGET_DIR/$dir" 2>/dev/null || umount -l "$TARGET_DIR/$dir" 2>/dev/null
done
