#!/bin/bash
set -x
type=$1
freq=$2
date=`date`
cg_path="./sources/meta-antminer/recipes-bitmianer/cgminer/cgminer-1.0"
config_path="./sources/meta-antminer/recipes-bitmianer/initscripts/initscripts-1.0"

ps -aux | grep bitbake |awk {'print $2'} | xargs kill -9

sed -i -r "s/.*?echo \".*?\" > .*?compile_time/        echo \"$date\" > \${D}\${bindir}\/compile_time/g" ./sources/meta-antminer/recipes-bitmianer/initscripts/initscripts_1.0.bbappend
sed -i -r "s/.*?echo \".*?\" >> .*?compile_time/        echo \"Antminer $type\" >> \${D}\${bindir}\/compile_time/g" ./sources/meta-antminer/recipes-bitmianer/initscripts/initscripts_1.0.bbappend
sed -i -r "s/\"bitmain-freq\" : \".*\"/\"bitmain-freq\" : \"$freq\"/g" $config_path/cgminer_l3.conf.factory

rm $cg_path/cgminer-ltc.tar.bz2
if [ x${type} = "xL3" ];then
	cp $cg_path/cgminer-ltc.tar.bz2.l3 $cg_path/cgminer-ltc.tar.bz2
	sed -i -r "s/^Miner_TYPE = \".*\"/\Miner_TYPE = \"L3\"/g" ./conf/local.conf
fi

if [ x${type} = "xL3+" ];then
	cp $cg_path/cgminer-ltc.tar.bz2.l3+ $cg_path/cgminer-ltc.tar.bz2
	sed -i -r "s/^Miner_TYPE = \".*\"/\Miner_TYPE = \"L3+\"/g" ./conf/local.conf
fi


. environment-angstrom-v2013.06

bitbake -c clean initscripts -f -D
bitbake -c clean lighttpd -f -D
bitbake -c clean cgminer -f -D
bitbake -c clean sysvinit-inittab -f -D

rm -rf ./build/tmp-angstrom_v2013_06-eglibc/work/armv7ahf-vfp-neon-angstrom-linux-gnueabi/initscripts

bitbake LTC -f -D


cp ./deploy/eglibc/images/beaglebone/Angstrom-antminer_m-eglibc-ipk-v2013.06-beaglebone.rootfs.cpio.gz.u-boot ./image_items/initramfs.bin.SD
cd image_items
rm -rf *.tar.gz
c_time=`date "+%Y%m%d%H%M"`
file_name="Antminer-${type}-${c_time}-${freq}M.tar.gz"
tar -zcvf "$file_name" *

