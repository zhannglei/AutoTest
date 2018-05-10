#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vQAT_signOfLifeTests_UserSpace.ini
. ./common.sh

# install the QAT driver
cd ../Installation
. ./config.sh
. ./common_fun.sh
cd ${SCRIPT_FOLDER}
. ./install_rpm.sh
cd ${SCRIPT_FOLDER}
. ./install_qat.sh



cd ${INSTALL_FOLDER}/qat_package/build/
./cpa_sample_code signOfLife=1 >> qat_test.log

if [ `echo $?` == 0 ];then
    logger "`cat qat_test.log`"
	logger "${case} --check finished-- [PASS]"
else
    logger "`cat qat_test.log`"
	logger "${case} --check finished-- [FAIL]"
fi