#!/usr/bin/env bash

. ./common.sh

pci_info=`lspci`
for ((i=0; i<${#bus_list[*]}; i++));do
    bus_info=${bus_list[i]}
    eth=`echo ${bus_info} |awk '{print $1}'`
    exp_bus=`echo ${bus_info} |awk '{print $2}'`
    exp_net=`echo ${bus_info} |awk '{print $3}'`
    exp_driver=`echo ${bus_info} |awk '{print $4}'`
    get_driver=`ethtool -i ${eth} |egrep "^driver:" |awk '{print $2}'`
    b=`echo "${pci_info}" |egrep -i "${exp_bus}.*${exp_net}"`
    if [ "$b" != "" ] && [ "${get_driver}" == "${exp_driver}" ];then
        logger "device:{eth} bus:${exp_bus} net:${exp_net} driver:${get_driver} check [PASS]"
    else
        logger "device:{eth} bus:${exp_bus} net:${exp_net} driver:${get_driver} check [FAIL]"
    fi
done
