#!/bin/sh

# Cambiar de ruta al punto de montaje
cd /n

# Para evitar errores chase
mount -o subvol=@ /dev/sda1 .

# Conecta afuera con adentro de chroot.
mount --bind / /n/iso

# Entrar
chroot . bash --login
