#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vQAT_StatusCheck.ini
. ./common.sh



# Processing
ERROR=`cat /reboot.txt`
ERROR=$(($ERROR+0))
if [ ! -f /reboot.txt ];then

    # Check the QAT device
    for i in 7;do
        get_device=`lspci |grep Co- |grep "00:0${i}" | awk '{print $6}'`
        if [ "${get_device}" == "${exp_device}" ];then
            logger "00:0${i}.0 Co-processor:  Intel Corporation Device ${exp_device} (rev 04) [PASS]"
        else
            logger "00:0${i}.0 Co-processor:  Intel Corporation Device ${exp_device} (rev 04) [FAIL]"
            ERROR=$(($ERROR+1))
        fi

    done
    # install the QAT driver
    cd ../Installation
    . ./config.sh
    . ./common_fun.sh
    cd ${SCRIPT_FOLDER}
    . ./install_rpm.sh
    cd ${SCRIPT_FOLDER}
    . ./install_qat.sh

    # Check the acceleration kernel module
    a=$(echo `lsmod | grep "qa"  |awk '{print $1$4}'`)
    if [ "${a}" == "${exp_module}" ];then
        logger "The acceleration kernel module has be installed. [PASS]"
    else
        logger "The acceleration kernel module has not be installed. [FAIL]"
        ERROR=$(($ERROR+1))
    fi


    # Check the software is started
    for i in 0;do
        started_status=`service qat_service status | grep "qat_dev${i}" |awk '{print $NF}'`
        if [ "${started_status}" == up ];then
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [PASS]"
        else
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    done

    # Check the service restart function
    service qat_service restart

    sleep 2

    for i in 0;do
        started_status=`service qat_service status | grep "qat_dev${i}" |awk '{print $NF}'`
        if [ "${started_status}" == up ];then
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [PASS]"
        else
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    done

    # Check the service stop function
    service qat_service stop

    sleep 2

    for i in 0;do
        started_status=`service qat_service status | grep "qat_dev${i}" |awk '{print $NF}'`
        if [ "${started_status}" == down ];then
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: down
     [PASS]"
        else
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: down
     [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    done

    # Check the service shutdown function
    service qat_service shutdown

    sleep 2

    shutdown_status=`service qat_service status | grep "No devices found"`
    if [ $? == 0 ];then
        logger "Checking status of all devices: ${shutdown_status} [PASS]"
    else
        logger "Checking status of all devices: ${shutdown_status} [FAIL]"
        ERROR=$(($ERROR+1))
    fi

    echo $ERROR > /reboot.txt
    sleep 2 && reboot &
    logger "runner install --check continue-- [PASS]"
    exit
else
    for i in 0;do
        started_status=`service qat_service status | grep "qat_dev${i}" |awk '{print $NF}'`
        if [ "${started_status}" == up ];then
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [PASS]"
        else
            logger "qat_dev${i} - type: c6xxvf,  inst_id: 0,  bsf: 00:0$(($i+7)).0,  #accel: 1 #engines: 1 state: up
     [FAIL]"
            ERROR=$(($ERROR+1))
        fi
    done
fi

if [ "${ERROR}" == 0 ];then
	logger "${case} --check finished-- [PASS]"
else
	logger "${case} --check finished-- [FAIL]"
fi
