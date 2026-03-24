#!/bin/sh

apt reinstall golang-github-foxboron-go-uefi-dev
cp -vfr /usr/share/gocode/src/github.com/foxboron/go-uefi/tests/data/signatures/secureboot/* var/lib/sbctl
sbctl sign -s /boot/vmlinuz-6.12-x86_64
sbctl sign -s /boot/vmlinuz-6.19.8+deb14-amd64
sbctl sign -s /boot/vmlinuz-6.19.8+deb14-cloud-amd64
sbctl sign -s /boot/vmlinuz-6.19.8+deb14-rt-amd64
sbctl sign -s /boot/vmlinuz-6.19-x86_64
