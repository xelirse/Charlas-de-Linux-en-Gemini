#!/bin/sh

# Definimos la ruta larga en una variable para no escribirla mal
R=/run/media/manjaro/cfb49c22-87f2-47d9-a25b-310d8d8578af/@

# Desmontamos lo más interno primero
umount $R/dev/pts
umount $R/dev/shm
umount $R/dev
umount $R/proc
umount $R/sys
umount $R/run
umount $R/tmp
umount $R/etc/resolv.conf
