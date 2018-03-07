#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vQAT_Installation.ini
. ./common.sh

cd ../Installation
. ./config.sh
. ./common_fun.sh
cd ${SCRIPT_FOLDER}
. ./install_rpm.sh
cd ${SCRIPT_FOLDER}
. ./install_qat.sh

cd ${INSTALL_FOLDER}
if [ -f qat_package/build/adf_ctl ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi