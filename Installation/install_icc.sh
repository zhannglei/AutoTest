#!/usr/bin/env bash
. ./config.sh
. ./common_fun.sh
. ./install_license.sh

cd ${SCRIPT_FOLDER}
check_rpm_and_install

[ -f ${ICC_CONFIG_FILE} ] && source  ${ICC_CONFIG_FILE} intel64
[ -f ${ICC_VAR_FILE} ] && source  ${ICC_VAR_FILE} intel64
icc -v &> /dev/null
if [ $? == 0 ];then
    echo "ICC has already installed"
else
    cd ${ICC_FOLDER}
    icc_pkg=`ls |grep *.tgz`
    tar -xvf ${icc_pkg}
    sleep 10
    icc_folder=`ls -F|grep /$`
    cd $icc_folder
    ${SCRIPT_FOLDER}/install_icc.exp
    sleep 10
    source ${ICC_CONFIG_FILE} intel64
    add_bashrc "source ${ICC_CONFIG_FILE} intel64"
    icc -v &> /dev/null
    if [ $? == 0 ];then
        echo "ICC is installed successfully."
        cd ..
    else
        echo "ICC is installed failed."
    fi
fi

