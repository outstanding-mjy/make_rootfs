#!/bin/sh
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8
DEVICE=$1
METAFILE=$2
CONFIGMETAFIL="$METAFILE.conf"
LOOPDEVICE=$3

if [ $LOOPDEVICE"yes" == "yes" ]; then
which filefrag >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
echo "Error: filefrag is not installed"
exit 1
fi
fi
#which bc >/dev/null 2>&1
#if [ ! $? -eq 0 ]; then
#    echo "Error: bc is not installed"
#    exit 1
#fi

if [ $# -lt 1 ]; then
    echo "Error: Please supply block device path and loopdevice"
    echo "Eg. /dev/sda /tmp/metafile"
    exit 1
fi

[ ! -d ./meta ] && {
	mkdir meta
}

SECTOR_SIZE=$( blockdev --getss $DEVICE )
SECTORS=$( blockdev --getsz $DEVICE )

if [ $LOOPDEVICE"yes" != "yes" ]; then
losetup -d $LOOPDEVICE >/dev/null 2>&1
fi

MD_SIZE=$(( ((SECTORS + (2^18)-1) / 262144 * 8) + 2048 ))
FILE_SIZE=$(( MD_SIZE * SECTOR_SIZE ))
#MD_SIZE=$( echo "print((($SECTORS + (2<<17)-1) / 262144 * 8) + 2048)" | python - )
#FILE_SIZE=$( echo "print($MD_SIZE * $SECTOR_SIZE)" | python -)
if [ -f $METAFILE ]; then
	metasize=$( wc -c $METAFILE |awk '{print $1}' )	
	if [ $FILE_SIZE -gt $metasize ]; then
		echo "rm $METAFILE"
		rm -f $METAFILE $CONFIGMETAFIL
		sync
		echo "recreate $METAFILE"
		truncate -s $FILE_SIZE $METAFILE >/dev/null 2>&1
		sync
		[ $? -eq 0 ] && dd if=/dev/zero of=$METAFILE bs=$SECTOR_SIZE count=$MD_SIZE 
		if [ ! $? -eq 0 ]; then
		echo "Error: cannot truncate $METAFILE file "
		exit 1
		fi
		e4defrag -v $METAFILE 
		sync
	fi
else
	echo "create $METAFILE"
	rm -f $CONFIGMETAFIL
	truncate -s $FILE_SIZE $METAFILE >/dev/null 2>&1
	[ $? -eq 0 ] && dd if=/dev/zero of=$METAFILE bs=$SECTOR_SIZE count=$MD_SIZE 
	if [ ! $? -eq 0 ]; then
	echo "Error: cannot truncate $METAFILE file "
	exit 1
	fi
	e4defrag -v $METAFILE 
	sync

fi



if [ $LOOPDEVICE"yes" == "yes" ]; then
filefrag $METAFILE |grep "1 extent found"
if [ ! $? -eq 0 ]; then
    rm -f $METAFILE $CONFIGMETAFIL
    echo "Error: cannot create single extends $METAFILE file ,please try again "
    exit 1
fi
fi


if [ $LOOPDEVICE"yes" != "yes" ]; then
losetup $LOOPDEVICE $METAFILE >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Error: losetup create $LOOPDEVICE error "
    exit 1
fi
fi

