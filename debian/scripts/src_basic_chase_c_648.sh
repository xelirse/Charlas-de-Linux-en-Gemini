#!/bin/sh

x="
Ocurre al poner este comando
apt install sudo

Error:
Assertion 'path_is_absolute(p)' failed at src/basic/chase.c:648, function chase(). Aborting.

Solución
Salir de chroot
cd /n
mount -o subvol=@ /dev/sda1 .
"

