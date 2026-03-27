#!/bin/sh

echo "
# penguins-eggs configuration
# version: 26.3.21

# COMPRESIÓN Y SEGURIDAD
compression: xz
force_installer: true
root_passwd: evolution
user_opt: live
user_opt_passwd: evolution

# RUTAS DE ARRANQUE (No las cambies, son las de tu sistema)
initrd_img: /boot/initramfs-6.19-x86_64.img
vmlinuz: /boot/vmlinuz-6.19.8+deb14-rt-amd64
make_efi: true
make_isohybrid: true
make_md5sum: false

# CONFIGURACIÓN DE DESTINO (DISCO EXTERNO)
# Esta es la carpeta donde Eggs trabajará mientras comprime
path_work: /run/media/root/CCCOMA_X64FRE_EN-US_DV9/frankeinux/work
# Esta es la carpeta donde aparecerá tu archivo .iso al final
path_iso: /run/media/root/CCCOMA_X64FRE_EN-US_DV9/frankeinux
# Yolk
path_yolk: /run/media/root/CCCOMA_X64FRE_EN-US_DV9/frankeinux/yolk

# CONFIGURACIÓN DE SNAPSHOT
snapshot_basename: 'frankeinux'
snapshot_dir: /run/media/root/CCCOMA_X64FRE_EN-US_DV9/frankeinux/snapshots
snapshot_excludes: /etc/penguins-eggs.d/exclude.list
snapshot_prefix: ''

# OTROS
ssh_pass: false
theme: eggs
#timezone: America/Argentina/Buenos Aires
version: 26.3.21
" | tail -n+2 > /etc/penguins-eggs.d/eggs.yaml

eggs produce --excludes otro,dev,home,media,pkg,proc,run,sys,tmp --excludes static --basename frankeinux
