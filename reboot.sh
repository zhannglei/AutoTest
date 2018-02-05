#!/usr/bin/env bash

# set which type you want to run reboot
# if you want to run 800 counts , then set exp_count=800, other=""
# if you want to run reboot until 2018-02-02 14:00:00, please check your system time first,
#     then set exp_time=20180202140000, other=""
# if you want to run 24 hours, rm /time.txt first, then set exp_hour=24, other=""
# if you set more than two types, first one will take effect
exp_count=
exp_time=
exp_hour=24

n=`cat /count.txt`
n=$((n+1))
echo $n
echo $n > /count.txt
sleep 15

if [ "$exp_count" != "" ];then
    if [[ $n < $exp_count ]];then
        reboot
    fi
    exit
fi


if [ "$exp_time" != "" ];then
    now=`date "+%Y%m%d%H%M%S"`
    if [[ $now < $exp_time ]];then
        reboot
    fi
    exit
fi

if [ "$exp_hour" != "" ];then
    if [ ! -f /time.txt ];then
        echo $((`date "+%s"` + 3600 * $exp_hour)) > /time.txt
        sleep 3
        reboot
    else
        now=`date "+%s"`
        end_time=`cat /time.txt`
        if [[ $now < $end_time ]];then
            reboot
        fi
    fi
    exit
fi