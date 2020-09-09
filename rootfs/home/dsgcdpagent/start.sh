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

cd $HOME
[ ! -d ./meta ] && mkdir meta
#mount -t tmpfs tmpfs ./meta >/dev/null 2>&1
#[ -d ./metabak ] && cd metabak

localuuid=`dmidecode -t system |grep UUID |awk -F "[:]" '{print $2}' | tr -d ' '|tr -d '-'`
confuuid=`cat $HOME/dsgconf.json |python -c "import sys, json; print(json.load(sys.stdin)['uuid'])"`
if [ "$localuuid" != "$confuuid" ]; then
	echo "I'm not myself..."
	cd $HOME
       ./dsgcdpagent &
	exit 0
fi

$MODPROBE drbd minor_count=32 || {
	echo "Can not load the drbd module."$'\n'
	exit 5 

}

#for FILE in *.meta ; do
#	if [ -f $FILE ]; then
#	cp  $FILE ../meta
#	VOLUMEID=$( echo $FILE |sed -s 's/\.meta//' )	
#	losetup /dev/loop$VOLUMEID ../meta/$FILE >/dev/null 2>&1
#	fi
#done

$DRBDADM adjust-with-progress all
$DRBDADM --force primary all
[[ $? -gt 1 ]] && exit 20
$DRBDADM wait-con-int 
cd $HOME
./dsgcdpagent &
