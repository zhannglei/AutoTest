#!/usr/bin/env bash
function logger(){
    if [[ "$1" =~ "[PASS]" ]];then
        color="32m"
    elif [[ "$1" =~ "[FAIL]" ]];then
        color="31m"
    elif [[ "$1" =~ "[DEBUG]" ]];then
        color="33m"
    else
        color=""
    fi
    DATE=`date "+%Y-%m-%d %H:%M:%S"`
    if [ "${color}" != "" ];then
        echo -e "\033[${color}[${DATE}] $1\033[0m"
    fi
    if [ "${LOGFILE_PATH}" != "../log/" ];then
        DIR=`dirname ${LOGFILE_PATH}`
        if [ ! -d ${DIR} ];then
            mkdir -p ${DIR}
        fi
        echo "[${DATE}] $1" >> ${LOGFILE_PATH}
    fi
}

function sleep_seconds(){
    text=$1
    second=$2
    len=${#second}
    while [ "$second" != 0 ];do
        printf "$text "
        printf "%-${len}s\r" $second
        second=$(($second-1))
        sleep 1
    done
}