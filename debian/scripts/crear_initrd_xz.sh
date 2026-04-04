#!/bin/sh

mkdir -p ./lib/modules/6.19.10+deb14-amd64/kernel

cp -ar /lib/modules/6.19.10+deb14-amd64/kernel/drivers/ata ./lib/modules/6.19.10+deb14-amd64/kernel/
cp -ar /lib/modules/6.19.10+deb14-amd64/kernel/drivers/scsi ./lib/modules/6.19.10+deb14-amd64/kernel/
cp -ar /lib/modules/6.19.10+deb14-amd64/kernel/drivers/cdrom ./lib/modules/6.19.10+deb14-amd64/kernel/
cp -ar /lib/modules/6.19.10+deb14-amd64/kernel/fs/isofs ./lib/modules/6.19.10+deb14-amd64/kernel/

depmod -b . 6.19.10+deb14-amd64

find . | cpio -R 0:0 -o -H newc | xz --check=crc32 > ../initrd.img-6.19-x86_64.xz
# find . | cpio -R 0:0 -o -H newc | gzip -9 > ../initrd.img-6.19-x86_64.gz

cp -vf ../initrd.img-6.19-x86_64.xz ../live/initrd.img-6.19-x86_64.xz
# cp -vf ../initrd.img-6.19-x86_64.gz ../live/initrd.img-6.19-x86_64.gz
