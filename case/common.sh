#!/usr/bin/env bash
function logger(){
    if [[ "$1" =~ "[PASS]" ]];then
        color="32m"
    elif [[ "$1" =~ "[FAIL]" ]];then
        color="31m"
    elif [[ "$1" =~ "[DEBUG]" ]];then
        color="33m"
    fi
    DATE=`date "+%Y-%m-%d %H:%M:%S"`
    echo -e "\033[${color}[${DATE}] $1\033[0m"
    if [ "${LOGFILE}" != "" ];then
        DIR=`dirname ${LOGFILE}`
        if [ ! -d ${DIR} ];then
            mkdir -p ${DIR}
        fi
        echo "[${DATE}] $1" >> ${LOGFILE}
    fi
}