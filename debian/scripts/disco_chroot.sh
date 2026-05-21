#!/bin/bash
if [ "$EUID" -ne 0 ]; then echo "[-] Debe ser root."; exit 1; fi

TARGET_DIR="/run/media/manjaro/DISCO/@"
export XAUTH_FILE="/tmp/chroot_xauth.tmp"

# 1. Obtener la cookie del servidor X actual y guardarla en un archivo temporal legible
xauth extract - $DISPLAY > "$XAUTH_FILE"

# 2. Configuración de permisos gráficos
xhost +local:root

# 3. Montajes
for dir in tmp/.X11-unix run sys proc dev/pts dev; do umount -l "$TARGET_DIR/$dir" 2>/dev/null; done
mkdir -p "$TARGET_DIR"/{dev/pts,proc,sys,run,tmp/.X11-unix,root,etc}

mount --bind /dev "$TARGET_DIR/dev" && mount --make-private "$TARGET_DIR/dev"
mount --bind /dev/pts "$TARGET_DIR/dev/pts" && mount --make-private "$TARGET_DIR/dev/pts"
mount --bind /proc "$TARGET_DIR/proc" && mount --make-private "$TARGET_DIR/proc"
mount --bind /sys "$TARGET_DIR/sys" && mount --make-private "$TARGET_DIR/sys"
mount --bind /run "$TARGET_DIR/run" && mount --make-private "$TARGET_DIR/run"
mount --bind /tmp/.X11-unix "$TARGET_DIR/tmp/.X11-unix" && mount --make-private "$TARGET_DIR/tmp/.X11-unix"

export DISPLAY=$DISPLAY
export QT_X11_NO_MITSHM=1

# 4. Inyección del entorno dentro del chroot
# Pasamos la cookie y forzamos el uso de la misma
chroot "$TARGET_DIR" /bin/bash --login

# 5. Limpieza
rm -f "$XAUTH_FILE"
for dir in tmp/.X11-unix run sys proc dev/pts dev; do umount -l "$TARGET_DIR/$dir" 2>/dev/null; done
