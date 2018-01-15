#!/usr/bin/env bash

. ./common.sh

#step2: lspci | grep Ethernet
#step3: Check the driver and bus-info for eth0: ethtool -i eth0
#step4: Verify eth1 and eth2: ethtool -i eth1 ethtool -i eth2

ERROR=0

pci_info=`lspci`
for ((i=0; i<${#bus_list[*]}; i++));do
    bus_info=${bus_list[i]}
    eth=`echo ${bus_info} |awk '{print $1}'`
    exp_bus=`echo ${bus_info} |awk '{print $2}'`
    exp_net=`echo ${bus_info} |awk '{print $3}'`
    exp_driver=`echo ${bus_info} |awk '{print $4}'`
    get_driver=`ethtool -i ${eth} |egrep "^driver:" |awk '{print $2}'`
    b=`echo "${pci_info}" |egrep -i "${exp_bus}.*${exp_net}"`
    logger "$b [INFO]"
    logger "`ethtool -i ${eth}`"
    if [ "$b" != "" ] && [ "${get_driver}" == "${exp_driver}" ];then
        logger "device:{eth} bus:${exp_bus} net:${exp_net} driver:${get_driver} check [PASS]"
    else
        logger "device:{eth} bus:${exp_bus} net:${exp_net} driver:${get_driver} check [FAIL]"
        ERROR=$(($ERROR+1))
    fi
done

if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi