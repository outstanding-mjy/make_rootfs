# make_rootfs

#制作ignited.gz 

find . | cpio -H newc -o | gzip -9 -n >/home/dsg/viz/test/iso/CD_root/isolinux/initrd.gz

#制作iso

mkisofs -o output.iso -b isolinux/isolinux.bin -c  isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table CD_root  

#登陆后

iscisid

modprobe libiscsi

modprobe libiscsi_tcp

modprobe sd_mod

modprobe vmw_pvscsi

#查看网卡

lspci

#添加ip和路由

modprobe vmxnet3

ifconfig eth0 ip
route add default gw 网关