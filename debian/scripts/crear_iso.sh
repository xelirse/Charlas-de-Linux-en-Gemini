#!/bin/sh

mkdir -pv /iso/boot/grub
mkdir -pv /iso/live

cp -v /vmlinuz /iso/live/vmlinuz
cp -v /usr/lib/grub/i386-pc/eltorito.img /iso/boot/grub/eltorito.img
cp -v /boot/initrd.img-6.19-x86_64 /iso/live/initrd.img-6.19-x86_64.zstd

echo "set default=0
set timeout=3
menuentry \"Frankeinux Live (Debian Sid)\" {
    linux /live/vmlinuz boot=live quiet
    initrd /live/initrd.img-6.19-x86_64.zstd
}" > "/iso/boot/grub/grub.cfg"

mksquashfs / /iso/live/filesystem.squashfs -e \
proc sys dev run tmp mnt media iso trixie debian_trixie otro \
"root/.config/vivaldi/Default/Local Extension Settings" \
"root/.config/vivaldi/Default/Session Storage" \
"root/.config/vivaldi/Safe Browsing" \
root/.cache \
root/.config/vivaldi/Default/IndexedDB \
root/.config/vivaldi/Default/Sessions \
root/.config/vivaldi/Default/TransportSecurity \
root/.config/vivaldi/Default/shared_proto_db \
root/.local/share/gvfs-metadata \
frankeinux_dist.iso

xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "FRANKEINUX" \
  -output frankeinux_dist.iso \
  -J -R \
  -graft-points \
  -b boot/grub/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --grub2-boot-info \
  /iso

echo "Comando para probar el iso
qemu-system-x86_64 -enable-kvm -m 2G -cdrom frankeinux_dist.iso
"
