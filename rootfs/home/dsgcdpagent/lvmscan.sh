#!/bin/sh
/usr/sbin/vgscan
/usr/sbin/vgchange -ay
/usr/sbin/vgmknodes
