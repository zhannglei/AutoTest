#!/usr/bin/env bash

. ./common.sh

ERROR=0

vm_ip=`ifconfig |grep "192.168.0." |awk '{print $2}'`
vm_info=`cat ../tmp/${case} |grep "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
count=`echo "${vm_info}" |grep COUNT= |awk -F \= '{print $2}'`
other_info=`cat ../tmp/${case} |grep -v "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
other_info_mac_1=`echo "$other_info" |grep 'P0_MAC=' |awk -F \= '{print $2}'`
other_info_mac_2=`echo "$other_info" |grep 'P1_MAC=' |awk -F \= '{print $2}'`
other_info_ip_1=`echo "$other_info" |grep 'P0_IP=' |awk -F \= '{print $2}'`
other_info_ip_2=`echo "$other_info" |grep 'P1_IP=' |awk -F \= '{print $2}'`


if [ "$count" == 0 ];then
    cd ../Installation
    export ADD_PATCH=1
    . ./config.sh
    . ./common_fun.sh
    cd ${SCRIPT_FOLDER}
    . ./install_rpm.sh
    cd ${SCRIPT_FOLDER}
    . ./install_icc.sh
    cd ${SCRIPT_FOLDER}
    . ./install_dpdk.sh

    dpdk_pkg=`ls -F ${INSTALL_FOLDER} |grep dpdk.*/$`
    if [ "$dpdk_pkg" == "" ];then
        ERROR=$((ERROR+1))
    else
        cd ~/AutoTest/Installation
        . ./bind_port.sh
        cd ${INSTALL_FOLDER}/dpdk*/examples/l2fwd/build
        ./l2fwd -c 0xe -n 3 -- -p 0x3 -0${other_info_mac_0} -1${other_info_mac_1} &
        logger "${case} --check finished-- [DEBUG]"
    fi

elif [ "$count" == 1 ];then
    other_info=`cat ../tmp/${case} |grep -v "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
    other_eth1_ip=`echo "$other_info" |grep 'P0_IP=' |awk -F \= '{print $2}'`

    cd ~/bkctest

    scapy_tar=`ls | grep scapy*.zip`
    unzip $scapy_tar
    scapy_folder=`ls -F | grep scapy.*/$`
    cd ${scapy_folder}
    python setup.py install
    cd ~/AutoTest/case
    rpm -i ~/AutoTest/Installation/rpm/tcl-8.5.13-8.el7.x86_64.rpm
    rpm -i ~/AutoTest/Installation/rpm/expect-5.45-14.el7_1.x86_64.rpm
    tcpdump -i eth1 -b -c 10 > /tcpdump.log &
    sleep 5
    ./JumboFrame.exp "${other_info_mac_1}" "${other_info_ip_1}" "${other_info_mac_2}" "${other_info_ip_2}"

    count=`cat /tcpdump.log |grep -c 8800`
    if [ "${count}" -ge 10 ];then
        logger "get 8800 count ${count} [PASS]"
    else
        ERROR=$((ERROR+1))
        logger "get 8800 count ${count} [FAIL]"
    fi
    logger "cat /tcpdump.log [DEBUG]"
    if [ "${ERROR}" == 0 ];then
        logger "${case} --check finished-- [PASS]"
    else
        logger "${case} --check finished-- [FAIL]"
    fi
fi
