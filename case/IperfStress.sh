#!/usr/bin/env bash

. ./common.sh

ERROR=0

vm_ip=`ifconfig |grep "192.168.0." |awk '{print $2}'`
vm_info=`cat ../tmp/${case} |grep "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
count=`echo "${vm_info}" |grep COUNT= |awk -F \= '{print $2}'`
rpm -i ../Installation/rpm/iperf*.rpm


if [ "$count" == 0 ];then
    iperf3 -s &
    sleep 3
    logger "${case} --check finished-- [DEBUG]"
elif [ "$count" == 1 ];then
    other_info=`cat ../tmp/${case} |grep -v "SSH_IP=$vm_ip" |sed 's/ /\n/g'`
    other_eth1_ip=`echo "$other_info" |grep 'P0_IP=' |awk -F \= '{print $2}'`
    if [ "$type" == "udp" ];then
        iperf3 -c $other_eth1_ip -u -p 5201 -t 14400 |tee -a iperf.log
    elif [ "$type" == "tcp" ];then
        iperf3 -c $other_eth1_ip -p 5201 -t 14400 |tee -a iperf.log
    else
        ERROR=$((ERROR+1))
    fi
    # result=`tail -4 log.log | head -n1 |awk '{print $7}'`
    if [ $? != 0 ];then
        logger "iperf stress test [FAIL]"
        ERROR=$((ERROR+1))
    fi

    cat iperf.log |grep -i "iperf done"
    if [ $? == 0 ];then
        logger "iperf stress test [PASS]"
    else
        logger "iperf stress test [FAIL]"
        ERROR=$((ERROR+1))
    fi

    logger "`cat iperf.log`"

    if [ "${ERROR}" == 0 ];then
        logger "${case} --need to check the result-- [CHECK]"
        logger "${case} --check finished-- [PASS]"
    else
        logger "${case} --check finished-- [FAIL]"
    fi
fi
