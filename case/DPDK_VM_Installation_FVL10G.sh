#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/DPDK_VM_Installation_FVL10G.ini
. ./common.sh

cd ../Installation

. ./config.sh
. ./common_fun.sh
cd ${SCRIPT_FOLDER}
. ./install_rpm.sh
cd ${SCRIPT_FOLDER}
. ./install_icc.sh
cd ${SCRIPT_FOLDER}
. ./install_dpdk.sh

cd ${INSTALL_FOLDER}/${dpdk_pkg}

if [ -f x86_64-native-linuxapp-icc/kmod/igb_uio.ko ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi


