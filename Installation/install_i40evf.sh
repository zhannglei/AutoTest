#!/usr/bin/env bash

. ./config.sh
. ./common_fun.sh

cd ${I40E_FOLDER}

i40e_pkg=`ls -F |grep "i40e.*/$"`
if [ "${i40e_pkg}" == "" ];then
    i40e_tar=`ls -F |grep "i40e.*[^/]$"`
    tar -xf ${i40e_tar}
    i40e_pkg=`ls -F |grep "i40e.*/$"`
fi

cd ${i40e_pkg}src

make install
rmmod i40evf
modprobe i40evf

dhclient -r eth1
dhclient -r eth2

sleep 2
dhclient
sleep 5
