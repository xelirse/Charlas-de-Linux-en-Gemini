#!/bin/sh

pacman -Sy manjaro-keyring archlinux-keyring
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux manjaro
pacman -S apt --allow-nodeps --needed --overwrite "*" --noprofirm
