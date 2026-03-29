xorriso -as mkisofs \
  -iso-level 3 \
  -full-iso9660-filenames \
  -volid "FRANKEINUX" \
  -output /frankeinux_dist.iso \
  -J -R \
  -graft-points \
  -b boot/grub/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --grub2-boot-info \
  /iso

echo "Comando para probar el iso
qemu-system-x86_64 -enable-kvm -m 2G -cdrom frankeinux_dist.iso
"
