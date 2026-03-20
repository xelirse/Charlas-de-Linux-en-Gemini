#!/bin/sh

apt install dialog
dpkg --configure -a
export DEBIAN_FRONTEND=noninteractive apt-get install -f
apt reinstall dialog debconf
