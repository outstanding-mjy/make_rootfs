#!/bin/bash
export PATH=$PATH:/usr/bin:/usr/sbin
export LANG=en_US.UTF-8

which filefrag >/dev/null 2>&1
if [ ! $? -eq 0 ]; then
    echo "Error: filefrag is not installed"
    exit 1
fi
if [ $# -lt 3 ]; then
    echo "Error: Please supply block device path and metafile"
    echo "Eg. /dev/sda /home/dsgcdpagent/0.meta 1/0"
    exit 1
fi


DEVICE=$1
METAFILE=$2
RESOURCE=$3

MOUNTED_DEV=$( df -P $METAFILE | awk 'NR==2{print $1}' )

lsblk -pP $DEVICE |grep $MOUNTED_DEV > /dev/null 
[ ! $? -eq 0 ] &&  { echo "the device not contain the metafile"; exit 1; }

if [ $MOUNTED_DEV"yes" == "yes" ]; then
	echo "cannot find the metafile device "
	exit 1
fi

D_TYPE=$( lsblk -Pp  $MOUNTED_DEV | awk 'NR==1{print $6}' )

echo "$MOUNTED_DEV $D_TYPE"


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
	EXTENDS=$( filefrag -b512 -v $METAFILE | awk 'NR>=4{print $4 ":" $6  }' |awk -F":" '{print $1 $2}' )
	for EXTEND in $EXTENDS ; do
		echo "$EXTEND"
		begin=$( echo $EXTEND | awk -F"." '{print $1}' )
		len=$( echo $EXTEND | awk -F"." '{print $3}' )
		echo "len=$len"
		[ -z $len ] && continue
		BEGIN=$( echo "$begin + $PARTOFFSET+$LVM_OFFSET" | bc )
		END=$( echo "$len + $BEGIN " | bc )
		echo "drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END"
		drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END
	done
	;;
'TYPE="part"')
	if [ $MOUNTED_DEV == $DEVICE]; then
	PARTOFFSET=0
	else
	PARTOFFSET=$( blkid -ip $LVMDEV |grep PART_ENTRY_OFFSET |sed 's/PART_ENTRY_OFFSET=//' )	
	fi
	
	EXTENDS=$( filefrag -b512 -v $METAFILE | awk 'NR>=4{print $4 ":" $6  }' |awk -F":" '{print $1 $2}' )
	for EXTEND in $EXTENDS ; do
		begin=$( echo $EXTEND | awk -F"." '{print $1}' )
		len=$( echo $EXTEND | awk -F"." '{print $3}' )
		[ -z $len ] && continue
		BEGIN=$( echo "$begin + $PARTOFFSET" | bc )
		END=$( echo "$len + $BEGIN" | bc )
		echo "drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END"
		drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END
	done

	;;
'TYPE="disk"')
	PARTOFFSET=0
	EXTENDS=$( filefrag -b512 -v $METAFILE | awk 'NR>=4{print $4 ":" $6  }' |awk -F":" '{print $1 $2}' )
	for EXTEND in $EXTENDS ; do
		begin=$( echo $EXTEND | awk -F"." '{print $1}' )
		len=$( echo $EXTEND | awk -F"." '{print $3}' )
		[ -z $len ] && continue
		BEGIN=$( echo "$begin + $PARTOFFSET" | bc )
		END=$( echo "$len + $BEGIN" | bc )
		echo "drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END"
		drbdadm setnodup $RESOURCE --nostart=$BEGIN --nostop=$END
	done
	;;
*)	
	echo "disk type unsupported"
	exit 1
	;;
esac
