#!/bin/bash
#
# chkconfig: - 01 20
# description: Loads and unloads the dsgcdp module
#
### BEGIN INIT INFO
# Provides: dsgcdpagent
# Required-Start: $local_fs 
# Required-Stop:  $local_fs 
# Default-Start:
# Default-Stop:   0 1 6
# Short-Description:    Control dsgcdp .
# Description:    Control all dsgcdp resources.
#	You SHOULD NOT enable this init script
#	Start will try to:
#	start dsgcdpagent
#	  load the DRBD driver module,
#	Stop will try to:
#	   stop dsgcdpagent
### END INIT INFO

DRBDADM="drbdadm"
DRBDSETUP="drbdsetup"
PROC_DRBD="/proc/drbd"
MODPROBE="/sbin/modprobe"
RMMOD="/sbin/rmmod"
UDEV_TIMEOUT=10
ADD_MOD_PARAM="minor_count=32"
HOME="/home/dsgcdpagent"

PATH=/usr/sbin:/sbin:$PATH

# we only use these two functions, define fallback versions of them ...
log_daemon_msg() { echo -n "${1:-}: ${2:-}"; }
log_end_msg() { echo "."; }
# ... and let the lsb override them, if it thinks it knows better.
if [ -f /lib/lsb/init-functions ]; then
    . /lib/lsb/init-functions
fi

assure_module_is_loaded()
{
    [ -e "$PROC_DRBD" ] && return

    $MODPROBE -s dsg_drbd $ADD_MOD_PARAM || {
	echo "Can not load the drbd module."$'\n'
	exit 5 # LSB for "not installed"
    }
    # tell klogd to reload module symbol information ...
    [ -e /var/run/klogd.pid ] && [ -x /sbin/klogd ] && /sbin/klogd -i
}

drbd_pretty_status()
{
	local proc_drbd=$1
	# add resource names
	if ! type column &> /dev/null ||
	   ! type paste &> /dev/null ||
	   ! type join &> /dev/null ||
	   ! type sed &> /dev/null ||
	   ! type tr &> /dev/null
	then
		cat "$proc_drbd"
		return
	fi
	sed -e '2q' < "$proc_drbd"
	sed_script=$(
		i=0;
		_sh_status_process() {
			let i++ ;
			stacked=${_stacked_on:+"^^${_stacked_on_minor:-${_stacked_on//[!a-zA-Z0-9_ -]/_}}"}
			printf "s|^ *%u:|%6u\t&%s%s|\n" \
				$_minor $i \
				"${_res_name//[!a-zA-Z0-9_ -]/_}" "$stacked"
		};
		eval "$(drbdadm sh-status)" )

	p() {
		sed -e "1,2d" \
		      -e "$sed_script" \
		      -e '/^ *[0-9]\+: cs:Unconfigured/d;' \
		      -e 's/^\(.* cs:.*[^ ]\)   \([rs]...\)$/\1 - \2/g' \
		      -e 's/^\(.* \)cs:\([^ ]* \)st:\([^ ]* \)ds:\([^ ]*\)/\1\2\3\4/' \
		      -e 's/^\(.* \)cs:\([^ ]* \)ro:\([^ ]* \)ds:\([^ ]*\)/\1\2\3\4/' \
		      -e 's/^\(.* \)cs:\([^ ]*\)$/\1\2/' \
		      -e 's/^ *[0-9]\+:/ x &??not-found??/;' \
		      -e '/^$/d;/ns:.*nr:.*dw:/d;/resync:/d;/act_log:/d;' \
		      -e 's/^\(.\[.*\)\(sync.ed:\)/... ... \2/;/^.finish:/d;' \
		      -e 's/^\(.[0-9 %]*oos:\)/... ... \1/' \
		      < "$proc_drbd" | tr -s '\t ' '  ' 
	}
	m() {
		join -1 2 -2 1 -o 1.1,2.2,2.3 \
			<( ( drbdadm sh-dev all ; drbdadm -S sh-dev all ) | cat -n | sort -k2,2) \
			<(sort < /proc/mounts ) |
			sort -n | tr -s '\t ' '  ' | sed -e 's/^ *//'
	}
	# echo "=== p ==="
	# p
	# echo "=== m ==="
	# m
	# echo "========="
	# join -a1 <(p|sort) <(m|sort)
	# echo "========="
	(
	echo m:res cs ro ds p mounted fstype
	join -a1 <(p|sort) <(m|sort) | cut -d' ' -f2-6,8- | sort -k1,1n -k2,2
	) | column -t
}



run_hook()
{
	n="hook_$1"
	if t=$(type -t "$n") && [[ "$t" == "function" ]] ; then
		shift
		"$n" "$@"
	fi
}

[ ! -d $HOME ] && {
	echo "cannot find home dir\n"
	exit 1
}

cd $HOME
[ ! -d ./meta ] && mkdir meta

localuuid=`dmidecode -t system |grep UUID |awk -F "[:]" '{print $2}' | tr -d ' '|tr -d '-'`
confuuid=`cat $HOME/dsgconf.json |python -c "import sys, json; print(json.load(sys.stdin)['uuid'])"`
case "$1" in
    start)
    if [ "$localuuid" != "$confuuid" ]; then
    echo "I'm not myself..."
    cd $HOME
    ./dsgcdpagent &
    exit 0
    fi
    $DRBDADM adjust-with-progress all
    [[ $? -gt 1 ]] && exit 20
    $DRBDADM --force primary all
    $DRBDADM wait-con-int 
    cd $HOME
    ./dsgcdpagent &

	;;
    stop)
	killall dsgcdpagent
	log_end_msg 0
	;;
    reload)
	$DRBDADM sh-nop
	[[ $? = 127 ]] && exit 5 # LSB for "not installed"
	log_daemon_msg  "Reloading DRBD configuration"
	$DRBDADM adjust all
	run_hook reload
	log_end_msg 0
	;;
    restart|force-reload)
	( . $0 stop )
	( . $0 start )
	;;
    *)
	echo "Usage: /etc/init.d/dsgcdpagent {start|stop|reload|restart|force-reload}"
	exit 1
	;;
esac

exit 0
