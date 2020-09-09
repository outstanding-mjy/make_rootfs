#!/bin/bash

localuuid=`dmidecode -t system |grep UUID |awk -F "[:]" '{print $2}' | tr -d ' '|tr -d '-'`
confuuid=`cat dsgconf.json |python -c "import sys, json; print(json.load(sys.stdin)['uuid'])"`
if [ "$localuuid" == "$confuuid" ]; then
	echo "pass"
else
	echo "no pass"
fi
