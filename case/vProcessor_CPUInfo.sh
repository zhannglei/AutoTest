#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vProcessor_CPUInfo.ini
. ./common.sh

ERROR=0

# processor
for i in 0 1 2 3;do
    info=`cat /proc/cpuinfo |grep -A24 "processor\s:\s${i}"`
    get_processor=`echo "${info}" |grep "processor\s:" |awk -F \: '{print $2}' |sed 's/^\s*//g'`
    get_model_name=`echo "${info}" |grep 'model name'|awk -F \: '{print $2}' |sed 's/^\s*//g'`
    get_cpu_fre=`echo "${info}" |grep 'cpu MHz'|awk -F \: '{print $2}' |sed 's/^\s*//g'`

    if [ "${get_model_name}" == "${exp_model_name_1}" ];then
        if [[ "${get_cpu_fre}" > "${exp_cpu_fre_1}" ]];then
            logger "CPU$i model NAME: ${get_model_name} , CPU frequency: ${get_cpu_fre} [PASS]"
        else
            logger "CPU$i model NAME: ${get_model_name} , CPU frequency: ${get_cpu_fre} [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    elif [ "${get_model_name}" == "${exp_model_name_2}" ];then
        if [[ "${get_cpu_fre}" > "${exp_cpu_fre_2}" ]];then
            logger "CPU$i model NAME: ${get_model_name} , CPU frequency: ${get_cpu_fre} [PASS]"
        else
            logger "CPU$i model NAME: ${get_model_name} , CPU frequency: ${get_cpu_fre} [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    else
        logger "CPU$i model NAME: ${get_model_name} [FAIL]"
        ERROR=$(($ERROR+1))
    fi
done
logger "`cat /proc/cpuinfo` [INFO]"

if [ "${ERROR}" == 0 ];then
	logger "${case} --check finished-- [PASS]"
else
	logger "${case} --check finished-- [FAIL]"
fi