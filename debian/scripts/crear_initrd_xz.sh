#!/bin/sh

depmod -b . 6.19.10+deb14-amd64
umount -l ./proc ./sys
find . | cpio -R 0:0 -o -H newc | xz --check=crc32 --threads=0 > ../initrd.img-6.19-x86_64.xz
