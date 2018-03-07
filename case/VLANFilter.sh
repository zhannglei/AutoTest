#!/usr/bin/env bash

. ./common.sh

ERROR=0

vm_ip=`ifconfig |grep "192.168.0." |awk '{print $2}'`
vm_info=`cat ../tmp/${case} |grep "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
count=`echo "${vm_info}" |grep COUNT= |awk -F \= '{print $2}'`

if [ "$count" == 0 ];then
    python ../tools/ser.py &
    logger "${case} --check finished-- [DEBUG]"
elif [ "$count" == 1 ];then
    other_info=`cat ../tmp/${case} |grep -v "SSH_IP=$vm_ip" |sed 's/ /\n/g'`

    other_eth1_ip=`echo "$other_info" |grep 'P0_IP=' |awk -F \= '{print $2}'`
    ping -I eth1 $other_eth1_ip -c 4
    if [ $? == 0 ];then
        logger "ping eth1 $other_eth1_ip [PASS]"
    else
        logger "ping eth1 $other_eth1_ip [FAIL]"
        ERROR=$((ERROR+1))
    fi

    other_eth2_ip=`echo "$other_info" |grep 'P1_IP=' |awk -F \= '{print $2}'`
    ping -I eth2 $other_eth2_ip -c 4
    if [ $? == 0 ];then
        logger "ping eth2 $other_eth2_ip [PASS]"
    else
        logger "ping eth2 $other_eth2_ip [FAIL]"
        ERROR=$((ERROR+1))
    fi

    other_ssh_ip=`echo "$other_info" |grep 'SSH_IP=' |awk -F \= '{print $2}'`
    cmd="ifconfig eth1 |grep inet6  |awk '{print \$2}'"
    other_eth1_ipv6_address=`python ../tools/cli.py -i ${other_ssh_ip} -c "${cmd}"`
    ping6 -I eth1 $other_eth1_ipv6_address -c 4
    if [ $? == 0 ];then
        logger "ping eth2 $other_eth1_ipv6_address [PASS]"
    else
        logger "ping eth2 $other_eth1_ipv6_address [FAIL]"
        ERROR=$((ERROR+1))
    fi

    cmd="ifconfig eth2 |grep inet6  |awk '{print \$2}'"
    other_eth2_ipv6_address=`python ../tools/cli.py -i ${other_ssh_ip} -c "${cmd}"`
    ping6 -I eth2 $other_eth2_ipv6_address -c 4
    if [ $? == 0 ];then
        logger "ping eth2 $other_eth2_ipv6_address [PASS]"
    else
        logger "ping eth2 $other_eth2_ipv6_address [FAIL]"
        ERROR=$((ERROR+1))
    fi

    if [ "${ERROR}" == 0 ];then
        logger "${case} --check finished-- [PASS]"
    else
        logger "${case} --check finished-- [FAIL]"
    fi
fi
