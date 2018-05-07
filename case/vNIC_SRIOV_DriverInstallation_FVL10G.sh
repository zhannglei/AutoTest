#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vNIC_SRIOV_DriverInstallation_FVL10G.ini
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

if [ "${version}" == "3.5.6" ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
