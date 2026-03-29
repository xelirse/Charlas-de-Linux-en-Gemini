#!/bin/sh

mkdir -pv /iso/boot/grub
mkdir -pv /iso/live

cp -v /vmlinuz /iso/live/vmlinuz
cp -v /usr/lib/grub/i386-pc/eltorito.img /iso/boot/grub/eltorito.img

echo "set default=0
set timeout=3
menuentry \"Frankeinux Live (Debian Sid)\" {
    linux /live/vmlinuz boot=live quiet
    initrd /live/initrd.img
}" > "/iso/boot/grub/grub.cfg"

mksquashfs / /iso/live/filesystem.squashfs -e proc sys dev run tmp mnt media iso trixie debian_trixie otro root/.cache frankeinux_dist.iso

xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "FRANKEINUX" \
  -output frankeinux_dist.iso \
  -graft-points \
  -b boot/grub/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --grub2-boot-info \
  /iso
