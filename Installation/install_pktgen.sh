#!/usr/bin/env bash
. ./config.sh
. ./common_fun.sh

check_dpdk_and_install

[ -f ${ICC_CONFIG_FILE} ] && source  ${ICC_CONFIG_FILE} intel64

cd ${PKTGEN_FOLDER}
pktgen_pkg=`ls -F ${INSTALL_FOLDER} |grep "pktgen.*/$"`
pktgen_tar=`ls -F |grep "pktgen.*[^/]$"`
[ "$pktgen_pkg" == "" ] && tar -xvf $pktgen_tar -C ${INSTALL_FOLDER}
pktgen_pkg=`ls -F ${INSTALL_FOLDER} |grep "pktgen.*/$"`
dpdk_pkg=`ls -F ${INSTALL_FOLDER} |grep "dpdk.*/$"`
export RTE_SDK=${INSTALL_FOLDER}/${dpdk_pkg}
export RTE_TARGET=x86_64-native-linuxapp-icc

cd ${INSTALL_FOLDER}
cd ${pktgen_pkg}

if [ -f app/x86_64-native-linuxapp-icc/pktgen ];then
    echo "Pktgen has already installed."
else
    rpm -q libpcap-devel-1.5.3-8.el7.x86_64
    if [ $? != 0 ];then
        echo "libpcap is not installed."
        exit 1
    fi

    make

    if [ -f app/x86_64-native-linuxapp-icc/pktgen ];then
        echo "Pktgen is installed successfully."
    else
        echo "Pktgen is installed failed."
        exit 1
    fi
fi

cp Pktgen.lua app/x86_64-native-linuxapp-icc/


