#!/bin/sh

mkdir -pv /iso/boot/grub
mkdir -pv /iso/live
mkdir -pv /iso/boot/grub/x86_64-emu

cp -v /vmlinuz /iso/live/vmlinuz
# cp -v /usr/lib/grub/i386-pc/eltorito.img /iso/boot/grub/eltorito.img
cp -v /boot/grub/x86_64-emu/kernel.img /iso/boot/grub/x86_64-emu/kernel.img
cp -v /boot/initrd.img-6.19-x86_64 /iso/live/initrd.img-6.19-x86_64.zstd
cp -rv /boot/grub/i386-pc /iso/boot/grub
cp -rv /boot/grub/x86_64-emu /iso/boot/grub

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
"root/.config/vivaldi/Default/Local Storage" \
"root/.config/vivaldi/Default/Network Action Predictor-journal" \
"root/.config/vivaldi/Default/History-journal" \
"root/.config/vivaldi/Default/Network Persistent State" \
"root/.config/vivaldi/Default/Site Characteristics Database" \
"root/.config/vivaldi/System Profile/Storage/ext" \
root/.cache \
root/.config/vivaldi/Default/IndexedDB \
root/.config/vivaldi/Default/Sessions \
root/.config/vivaldi/Default/TransportSecurity \
root/.config/vivaldi/Default/shared_proto_db \
root/.config/vivaldi/Default/Storage/ext \
root/.config/vivaldi/Default/Preferences \
root/.config/vivaldi/Default/QuotaManager-journal \
root/.config/geany/geany_socket_manjaro__0 \
root/.config/geany/session.conf \
root/.local/share/gvfs-metadata \
root/.local/share/recently-used.xbel \
root/.local/share/zeitgeist/activity.sqlite \
root/.local/share/zeitgeist/fts.index \
root/.node_repl_history \
usr/lib/debug \
usr/lib64/debug \
var/log/journal \
-comp xz -b 2M

rm -v /iso/frankeinux.iso
xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "FRANKEINUX" \
  -output /frankeinux.iso \
  -J -R \
  -graft-points \
  -b /boot/grub/x86_64-emu/kernel.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --grub2-boot-info \
  /iso

echo "Comando para probar el iso
qemu-system-x86_64 -enable-kvm -m 2G -cdrom /iso/frankeinux.iso
"
