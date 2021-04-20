#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8

which filefrag >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Error: filefrag is not installed"
    exit 1
fi
if [ $# -lt 1 ]; then
    echo "Error: Please supply metafile"
    echo "Eg. /home/dsgcdpagent/0.meta"
    exit 1
fi

METAFILE=$1

DEVICE=$( /home/dsgcdpagent/getsysdisk.sh $METAFILE )

MOUNTED_DEV=$( df -P $METAFILE | awk 'NR==2{print $1}' )

if [ -f $METAFILE.conf ]; then
	cat $METAFILE.conf
	exit 0
fi

lsblk -pP $DEVICE |grep $MOUNTED_DEV > /dev/null 
[ ! $? -eq 0 ] &&  { echo "the device not contain the metafile"; exit 1; }

if [ $MOUNTED_DEV"yes" == "yes" ]; then
	echo "cannot find the metafile device "
	exit 1
fi

D_TYPE=$( lsblk -Pp  $MOUNTED_DEV | awk 'NR==1{print $6}' )

case $D_TYPE in
'TYPE="lvm"')
	LVM_OFFSET=$( dmsetup table $MOUNTED_DEV |grep linear |awk '{print $5}'	)
	MAJMINOR=$( dmsetup table $MOUNTED_DEV |grep linear |awk '{print $4}' )
        LVMDEV=$( lsblk -pP $DEVICE |grep "MAJ:MIN=\"$MAJMINOR\"" |awk '{print $1}' | sed 's/NAME=//'|sed 's/"//g' )
	if [ $LVMDEV == $DEVICE ]; then
	PARTOFFSET=0
	else
	PARTOFFSET=$( blkid -ip $LVMDEV |grep PART_ENTRY_OFFSET |sed 's/PART_ENTRY_OFFSET=//' )	
	fi
	EXTENDS=$( filefrag -b512 -v $METAFILE | awk -F":" 'NR>=4{print $3":"$4}' )
	begin=$( echo $EXTENDS | awk -F"." '{print $1}' )
	len=$( echo $EXTENDS | awk -F":" '{print $2}' )
	[ -z $len ] && continue
	BEGIN=$( echo "print($begin + $PARTOFFSET+$LVM_OFFSET)" | python - )
	END=$( echo "print($len + $BEGIN) " | python - )
	echo "$DEVICE --nostart=$BEGIN --nostop=$END"
	echo "$DEVICE --nostart=$BEGIN --nostop=$END" > $METAFILE.conf
	;;
'TYPE="part"')
	if [ $MOUNTED_DEV == $DEVICE ]; then
	PARTOFFSET=0
	else
	PARTOFFSET=$( blkid -ip $MOUNTED_DEV |grep PART_ENTRY_OFFSET |sed 's/PART_ENTRY_OFFSET=//' )	
	fi

	EXTENDS=$( filefrag -b512 -v $METAFILE | awk -F":" 'NR>=4{print $3":"$4}' )
	begin=$( echo $EXTENDS | awk -F"." '{print $1}' )
	len=$( echo $EXTENDS | awk -F":" '{print $2}' )
	[ -z $len ] && continue
	BEGIN=$( echo "print($begin + $PARTOFFSET)" | python - )
	END=$( echo "print($len + $BEGIN)" | python )
		echo "$DEVICE --nostart=$BEGIN --nostop=$END"
		echo "$DEVICE --nostart=$BEGIN --nostop=$END" > $METAFILE.conf

	;;
'TYPE="disk"')
	PARTOFFSET=0
	EXTENDS=$( filefrag -b512 -v $METAFILE | awk -F":" 'NR>=4{print $3":"$4}' )
	begin=$( echo $EXTENDS | awk -F"." '{print $1}' )
	len=$( echo $EXTENDS | awk -F":" '{print $2}' )
	[ -z $len ] && continue
	BEGIN=$( echo "print($begin + $PARTOFFSET)" | python - )
	END=$( echo "print($len + $BEGIN)" | python - )
	echo "$DEVICE --nostart=$BEGIN --nostop=$END"
	echo "$DEVICE --nostart=$BEGIN --nostop=$END" > $METAFILE.conf
	;;
*)	
	echo "disk type unsupported"
	exit 1
	;;
esac
