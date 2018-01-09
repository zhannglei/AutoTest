#!/usr/bin/env bash

. ./common.sh


for eth in eth1 eth2;do
    ifconfig ${eth} up
    sleep 2
    eth_info=`ifconfig ${eth} |grep ${eth} |awk -F \< '{print $2}' |awk -F \> '{print $1}'`

    if [[ "${eth_info}" == "UP,BROADCAST,RUNNING,MULTICAST" ]];then
        logger "${eth} up status check [PASS]"
    else
        logger "${eth} up status check [FAIL]"
    fi
    link=`ethtool ${eth} |grep "Link detected:" |awk '{print $3}'`
    if [ "${link}" == "yes" ];then
        logger "${eth} up Link Detected ${link} [PASS]"
    else
        logger "${eth} up Link Detected ${link} [FAIL]"
    fi
done


for eth in eth1 eth2;do
    ifconfig ${eth} down
    sleep 2
    eth_info=`ifconfig ${eth} |grep ${eth} |awk -F \< '{print $2}' |awk -F \> '{print $1}'`

    if [[ "${eth_info}" == "BROADCAST,MULTICAST" ]];then
        logger "${eth} down status check [FAIL]"
    else
        logger "${eth} down status check [PASS]"
    fi
    link=`ethtool ${eth} |grep "Link detected:" |awk '{print $3}'`
    if [ "${link}" == "no" ];then
        logger "${eth} down Link Detected ${link} [PASS]"
    else
        logger "${eth} down Link Detected ${link} [FAIL]"
    fi
done
