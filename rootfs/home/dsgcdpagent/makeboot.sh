#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8
if [ $# -lt 3 ]; then
    echo "make new grub boot menuconfig to /tmp/dsg_grub.conf"
    echo "Eg. kernelversion suffix /tmp/grub.conf modules ..."
    exit 1
fi
KERNELVER=$1
SUFFIX=$2
NEWBOOTFILE=$3
WITH_MODULES="--with=mptbase --with=mptctl --with=mptsas --with=mptscsih --with=mptspi --with=ch --with=3w-9xxx --with=hpsa --with=hptiop"
shift
shift
shift
MKINITRD=mkinitrd
GRUBMKCONFIG=grub2-mkconfig
KERNEL_VMZ="/boot/vmlinuz-$KERNELVER"
NEW_KERNEL_VMZ="$KERNEL_VMZ-$SUFFIX"

INITRAM="/boot/initramfs-$KERNELVER.img"
NEW_INITRAM="/boot/initramfs-$KERNELVER-$SUFFIX.img"

if [ ! -f $KERNEL_VMZ ]; then
	echo "Cannot find file $KERNEL_VMZ !"
	exit 1
fi 

while (($# > 0)); do
WITH_MODULES="$WITH_MODULES --with $1"
shift
done

$MKINITRD $WITH_MODULES --force $NEW_INITRAM $KERNELVER || exit 1
cp -f $KERNEL_VMZ $NEW_KERNEL_VMZ
$GRUBMKCONFIG > $NEWBOOTFILE
