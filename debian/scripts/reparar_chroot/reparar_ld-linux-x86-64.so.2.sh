#!/bin/sh

mkdir -p /n/lib64
cp -v /usr/lib/ld-linux-x86-64.so.2 /n/lib64/ld-linux-x86-64.so.2
chroot /n .
