#!/bin/sh

cd /n
mount -o subvol=@ /dev/sda1 .
manjaro-chroot . bash --login
