#!/bin/sh
echo "------Create rootfs directons......"
mkdir rootfs
cd rootfs
echo "--------Create root,dev......"
mkdir root dev etc bin sbin mnt sys proc lib home tmp var usr
mkdir usr/sbin usr/bin usr/lib usr/modules
mkdir mnt/usb mnt/nfs mnt/etc mnt/etc/init.d
mkdir lib/modules
chmod 1777 tmp
cd ..
echo "-------make direction done---------"
