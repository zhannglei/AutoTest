#!/usr/bin/env bash

. ./common.sh


# step2: Login VM and up the eth1 and eth2: ifconfig eth1 up/ ifconfig eth2 up/ ifconfig eth1/ ifconfig eth2
# step3: Check link status: ethtool eth1/ ethtool eth2
# step4: Down the eth1 and eth2: ifconfig eth1 down/ ifconfig eth2 down/ ifconfig eth1/ ifconfig eth2
# step5: Check link status: ethtool eth1/ ethtool eth2
ERROR=0

for eth in eth1 eth2;do
    ifconfig ${eth} up
    sleep 2
    logger "`ifconfig ${eth} |grep ${eth}` [INFO]"
    eth_info=`ifconfig ${eth} |grep ${eth} |awk -F \< '{print $2}' |awk -F \> '{print $1}'`

    if [ "${eth_info}" == "UP,BROADCAST,RUNNING,MULTICAST" ];then
        logger "${eth} up status check [PASS]"
    else
        logger "${eth} up status check [FAIL]"
        ERROR=$(($ERROR+1))
    fi
    logger "`ethtool ${eth}` [INFO]"
    link=`ethtool ${eth} |grep "Link detected:" |awk '{print $3}'`
    if [ "${link}" == "yes" ];then
        logger "${eth} up Link Detected ${link} [PASS]"
    else
        logger "${eth} up Link Detected ${link} [FAIL]"
        ERROR=$(($ERROR+1))
    fi

    if [ "${IS_SRIOV}" == "1" ];then
        speed=`ethtool ${eth} |grep "Speed" |awk '{print $2}'`
        if [ "${speed}" == "10000Mb/s" ];then
            logger "${eth} speed check [PASS]"
        else
            logger "${eth} speed check [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    fi
done


for eth in eth1 eth2;do
    ifconfig ${eth} down
    sleep 2
    logger "`ifconfig ${eth} |grep ${eth}` [INFO]"
    eth_info=`ifconfig ${eth} |grep ${eth} |awk -F \< '{print $2}' |awk -F \> '{print $1}'`

    if [ "${eth_info}" == "BROADCAST,MULTICAST" ];then
        logger "${eth} down status check [PASS]"
    else
        logger "${eth} down status check [FAIL]"
        ERROR=$(($ERROR+1))
    fi
    logger "`ethtool ${eth}` [INFO]"
    link=`ethtool ${eth} |grep "Link detected:" |awk '{print $3}'`
    if [ "${link}" == "no" ];then
        logger "${eth} down Link Detected ${link} [PASS]"
    else
        logger "${eth} down Link Detected ${link} [FAIL]"
        ERROR=$(($ERROR+1))
    fi
done

if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
