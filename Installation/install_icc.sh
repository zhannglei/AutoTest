#!/usr/bin/env bash
. ./config.sh
. ./common_fun.sh
. ./install_license.sh

cd ${SCRIPT_FOLDER}
check_rpm_and_install

[ -f ${ICC_CONFIG_FILE} ] && source  ${ICC_CONFIG_FILE} intel64
icc -v &> /dev/null
if [ $? == 0 ];then
    echo "ICC has already installed"
else
    cd ${ICC_FOLDER}
    [ ! -d parallel_studio_xe_2018_update1_professional_edition ] && tar -xvf parallel_studio_xe_2018_update1_professional_edition.tgz
    sleep 10
    cd parallel_studio_xe_2018_update1_professional_edition
    ${SCRIPT_FOLDER}/install_icc.exp
    sleep 10
    source ${ICC_CONFIG_FILE} intel64
    add_bashrc "source ${ICC_CONFIG_FILE} intel64"
    icc -v &> /dev/null
    if [ $? == 0 ];then
        echo "ICC is installed successfully."
        cd ..
        [ -d parallel_studio_xe_2018_update1_professional_edition ] && rm -rf parallel_studio_xe_2018_update1_professional_edition
    else
        echo "ICC is installed failed."
    fi
fi

