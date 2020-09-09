#!/bin/bash
PATH=$PATH:/usr/bin:/usr/sbin

LANG=en_US.UTF-8
DRBDADM="drbdadm"
DRBDSETUP="drbdsetup"
PROC_DRBD="/proc/drbd"
MODPROBE="/sbin/modprobe"
RMMOD="/sbin/rmmod"

HOME="/home/dsgcdpagent"

[ ! -d $HOME ] && {
	echo "cannot find home dir\n"
	exit 1
}

killall dsgcdpagent

[ -d $HOME/metabak ] || mkdir -p $HOME/metabak

cd $HOME/meta

#for FILE in *.meta ; do
#	if [ -f $FILE ]; then
#	cp  $FILE ../metabak/
#	fi
#done

#$DRBDADM down all


#for FILE in *.meta ; do
#	if [ -f $FILE ]; then
#	VOLUMEID=$( echo $FILE |sed -s 's/\.meta//' )	
#	losetup -d /dev/loop$VOLUMEID  >/dev/null 2>&1
#	dd if=$FILE of=$HOME/metabak/$FILE
#	fi
#done
#cd $HOME
#umount $HOME/meta
