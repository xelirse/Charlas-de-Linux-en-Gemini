#!/bin/sh

if [ ! "/usr/lib/x86_64-linux-gnu/libc.so.6" ] ; then
    mkdir -p /tmp/libc_rescue
    dpkg-deb -x /var/cache/apt/archives/libc6_2.42-13_amd64.deb /tmp/libc_rescue
    cp -rf /tmp/libc_rescue/* /
    /usr/sbin/ldconfig
    dpkg --configure -a
    cp -vf /lib/libc.* /usr/lib/x86_64-linux-gnu
    cp: target '/usr/lib/x86_64-linux-gnu': No such file or directory
    busybox cp -vf /lib/libc.* /usr/lib/x86_64-linux-gnu
    busybox ls -lh /lib/libc.so*
    busybox rm -v /usr/lib/libc.so.6.broken
    busybox rm -v /usr/lib/x86_64-linux-gnu/libc.so
    busybox rm -v /usr/lib/x86_64-linux-gnu/libc.so.6
    busybox rm -v //usr/lib/x86_64-linux-gnu/libc.so.6.0
    busybox rm -v /usr/lib/x86_64-linux-gnu/libc.so.6.0.0
    busybox cp -vf /lib/libc.* /usr/lib/x86_64-linux-gnu
    busybox ls -lh /usr/lib/x86_64-linux-gnu/libc.so.6*
fi
