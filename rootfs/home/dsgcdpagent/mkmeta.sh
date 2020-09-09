#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8
which bc >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Error: bc is not installed"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Error: Please supply block device path and loopdevice"
    echo "Eg. /dev/sda /tmp/metafile"
    exit 1
fi
DEVICE=$1
METAFILE=$2
#LOOPDEVICE=$3

#[ ! -d ./meta ] && {
#	mkdir meta
#	mount -t tmpfs tmpfs ./meta >/dev/null 2>&1
#}

SECTOR_SIZE=$( blockdev --getss $DEVICE )
SECTORS=$( blockdev --getsz $DEVICE )
#losetup -d $LOOPDEVICE >/dev/null 2>&1
#if [ ! -e $LOOPDEVICE ]; then
#rmmod loop
#modprobe loop max_loop=64
#fi

MD_SIZE=$( echo "((($SECTORS + (2^18)-1) / 262144 * 8) + 2048)" | bc )
FILE_SIZE=$( echo "$MD_SIZE * $SECTOR_SIZE" | bc)
truncate -s $FILE_SIZE $METAFILE >/dev/null 2>&1

[ $? -eq 0 ] && dd if=/dev/zero of=$METAFILE bs=$SECTOR_SIZE count=$MD_SIZE 

if [ ! $? -eq 0 ]; then
    echo "Error: cannot truncate $METAFILE file "
    exit 1
fi

#losetup $LOOPDEVICE $METAFILE >/dev/null 2>&1
#if [ ! $? -eq 0 ]; then
#    echo "Error: losetup create $LOOPDEVICE error "
#    exit 1
#fi

