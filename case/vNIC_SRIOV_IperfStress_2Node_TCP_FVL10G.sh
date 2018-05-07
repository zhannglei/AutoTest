#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ./common.sh
. ../config/vNIC_SRIOV_IperfStress_2Node_TCP_FVL10G.ini


driver=`ethtool -i eth1 | grep "^version" | awk '{print $2}'`
if [ "$driver" != 3.4.2 ];then

    cd ~

    cd ~/AutoTest/Installation

    . ./config.sh
    . ./common_fun.sh

    cd ${SCRIPT_FOLDER}
    . ./install_rpm.sh
    cd ${SCRIPT_FOLDER}
    . ./install_i40evf.sh


    logger "`modinfo i40evf` [INFO]"

fi

cd ~/AutoTest/case

. ./IperfStress.sh


