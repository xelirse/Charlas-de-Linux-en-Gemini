#!/bin/sh

# f_disco_chroot.sh - Entorno Chroot Gráfico Avanzado
# Versión: Detección robusta para sistemas con usr-merge (bin -> usr/bin)

if [ "$EUID" -ne 0 ]; then
  echo "[-] ERROR: Este script debe ejecutarse como root."
  exit 1
fi

# Ajustamos la detección a tu ruta específica donde SÍ está el sistema
TARGET_DIR="/run/media/manjaro/DISCO/@"

# 1. Limpieza de residuos (forzada)
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -l "$TARGET_DIR/$dir" 2>/dev/null
done

# 2. Validación de entorno (Buscamos bash en /usr/bin por el enlace simbólico)
if [ -f "$TARGET_DIR/usr/bin/bash" ]; then
    echo "[+] Sistema operativo válido detectado en $TARGET_DIR"
    CHROOT_SHELL="/usr/bin/bash"
else
    echo "[-] ERROR: No se encontró /usr/bin/bash en $TARGET_DIR"
    exit 1
fi

# 3. Preparación
xhost +local:root &>/dev/null
mkdir -p "$TARGET_DIR"/{dev/pts,proc,sys,run,tmp/.X11-unix,root,etc}

# Montajes
mount --bind /dev          "$TARGET_DIR/dev"          && mount --make-private "$TARGET_DIR/dev"
mount --bind /dev/pts      "$TARGET_DIR/dev/pts"      && mount --make-private "$TARGET_DIR/dev/pts"
mount --bind /proc         "$TARGET_DIR/proc"         && mount --make-private "$TARGET_DIR/proc"
mount --bind /sys          "$TARGET_DIR/sys"          && mount --make-private "$TARGET_DIR/sys"
mount --bind /run          "$TARGET_DIR/run"          && mount --make-private "$TARGET_DIR/run"
mount --bind /tmp/.X11-unix "$TARGET_DIR/tmp/.X11-unix" && mount --make-private "$TARGET_DIR/tmp/.X11-unix"

echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > "$TARGET_DIR/etc/resolv.conf"
[ -f "$HOME/.Xauthority" ] && cp "$HOME/.Xauthority" "$TARGET_DIR/root/"

# 4. Entrar al Chroot
echo "==> [CHROOT ACTIVO] Escribe 'exit' para salir."
chroot "$TARGET_DIR" env DISPLAY="$DISPLAY" HOME=/root LANG=es_AR.UTF-8 "$CHROOT_SHELL"

# 5. Limpieza
echo "==> Limpiando..."
for dir in tmp/.X11-unix run sys proc dev/pts dev; do
    umount -f "$TARGET_DIR/$dir" 2>/dev/null || umount -l "$TARGET_DIR/$dir" 2>/dev/null
done
