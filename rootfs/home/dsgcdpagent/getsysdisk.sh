#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8

if [ $# -lt 1 ]; then
    echo "Error: get system disk"
    echo "Eg. /home/dsgcdpagent/"
    exit 1
fi


METAFILE=$1

MOUNTED_DEV=$( df -P $METAFILE | awk 'NR==2{print $1}' )

if [ $MOUNTED_DEV"yes" == "yes" ]; then
	echo "cannot find the metapath device "
	exit 1
fi

D_TYPE=$( lsblk -Pp  $MOUNTED_DEV | awk 'NR==1{print $6}' )

while [ 1==1 ]
do
case $D_TYPE in
'TYPE="lvm"')
	MAJMINOR=$( dmsetup table $MOUNTED_DEV |grep linear |awk '{print $4}' )
        LVMDEV=$( lsblk -pP |grep "MAJ:MIN=\"$MAJMINOR\"" |awk '{print $1}' | sed 's/NAME=//'|sed 's/"//g' )
	D_TYPE=$( lsblk -Pp  $LVMDEV | awk 'NR==1{print $6}' )
	MOUNTED_DEV=$LVMDEV
	continue
	;;
'TYPE="part"')
	PART_DISK_MJ=$( blkid -ip $MOUNTED_DEV |grep PART_ENTRY_DISK |sed 's/PART_ENTRY_DISK=//' )
        MOUNTED_DEV=$( lsblk -pP |grep "MAJ:MIN=\"$PART_DISK_MJ\"" |awk '{print $1}' | sed 's/NAME=//'|sed 's/"//g' )
	D_TYPE=$( lsblk -Pp  $MOUNTED_DEV | awk 'NR==1{print $6}' )
	continue
	;;
'TYPE="disk"')
	echo $MOUNTED_DEV
	break
	;;
*)	
	echo "cannot find system disk"
	exit 1
	;;
esac
done
