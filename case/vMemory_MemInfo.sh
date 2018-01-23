#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vMemory_MemInfo.ini
. ./common.sh

ERROR=0

get_huge_total=`cat /proc/meminfo |grep -i HugePages_Total |awk '{print $2}'`
get_huge_free=`cat /proc/meminfo |grep -i HugePages_Free |awk '{print $2}'`
get_huge_rsvd=`cat /proc/meminfo |grep -i HugePages_Rsvd |awk '{print $2}'`
get_huge_surp=`cat /proc/meminfo |grep -i HugePages_Surp |awk '{print $2}'`
get_huge_size=`cat /proc/meminfo |grep -i Hugepagesize |awk '{print $2$3}'`

if [ "${get_huge_total}" == "${exp_huge_total}" ] && \
[ "${get_huge_free}" == "${exp_huge_free}" ] && \
[ "${get_huge_rsvd}" == "${exp_huge_rsvd}" ] && \
[ "${get_huge_surp}" == "${exp_huge_surp}" ] && \
[ "${get_huge_size}" == "${exp_huge_size}" ];then
    logger "Hugepage check [PASS]"
else
    logger "Hugepage check [FAIL]"
    ERROR=$(($ERROR+1))
fi
logger "`cat /proc/meminfo |grep -i HugePage` [INFO]"


if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
