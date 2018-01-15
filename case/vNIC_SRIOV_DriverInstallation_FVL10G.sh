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
. ./install_i40evf.sh

version=`modinfo i40evf|egrep "^version" |awk '{print $2}'`
logger "`modinfo i40evf` [INFO]"

if [ "${version}" == "3.1.4" ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
