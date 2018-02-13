#!/usr/bin/env bash

. ./config.sh
. ./common_fun.sh

#check_rpm_and_install
lspci |grep 37c9
if [ $? == 0 ];then
    cd ${INSTALL_FOLDER}
    echo ${INSTALL_FOLDER}
    if [ -f qat_package/build/adf_ctl ];then
        echo "QAT has already installed"
    else
        qat_tar=`ls -F ${QAT_FOLDER}|grep qat.*[^/]$`
        [ ! -d qat_package ] && mkdir qat_package
        if [ ! -f qat_package/installer.sh ];then
            tar -xf ${QAT_FOLDER}/${qat_tar} -C qat_package
        fi
        cd qat_package
        ${SCRIPT_FOLDER}/install_qat.exp
        if [ ! -f build/adf_ctl ];then
            echo "QAT is installed failed"
            exit 1
        else
            echo "QAT is installed successfully"
        fi
    fi
else
    echo "QAT device not exists"
fi