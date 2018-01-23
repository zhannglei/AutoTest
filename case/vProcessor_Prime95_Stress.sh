#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vProcessor_Prime95_Stress.ini
. ./common.sh

ERROR=0
if [ ! -f /runner/bin/scripts/run-prime.py ];then
    cd ~
    tar -xvf runner6.0.tar.gz
    cd runner6.0
    ./install.sh
    sleep 2 && reboot &
    logger "runner install --check continue-- [PASS]"
    exit
fi

rm script*.log
/runner/bin/scripts/run-prime.py -t 12:0:0

sleep 10
logger "`cat script*.log` [DEBUG]"
error=`cat script*.log |egrep "\[End Script]\]" |awk '{print $(NF-1)}'`
ERROR=$((ERROR+error))
if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
