#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vQAT_CryptodevQatAutotest.ini
. ./common.sh

ERROR=0


# install the QAT driver
cd ../Installation
. ./config.sh
. ./common_fun.sh
cd ${SCRIPT_FOLDER}
. ./install_rpm.sh
cd ${SCRIPT_FOLDER}
. ./install_qat.sh

# install the DPDK
cd ${SCRIPT_FOLDER}
. ./install_icc.sh
cd ${SCRIPT_FOLDER}
. ./install_dpdk.sh




# Check the QAT driver
cd ${INSTALL_FOLDER}
if [ -f qat_package/build/adf_ctl ];then
    echo "QAT is installed successfully."
else
    ERROR=$(($ERROR+1))
    echo "QAT is installed failed."
fi

# Check the DPDK is installed successfully
cd ${INSTALL_FOLDER}/${dpdk_pkg}
if [ ! -f x86_64-native-linuxapp-icc/kmod/igb_uio.ko ];then
    ERROR=$(($ERROR+1))
    echo "The DPDK is installed failed."
else
    echo "The DPDK is installed successfully."
fi

# Bind DPDK driver to QAT and NIC
cd ${SCRIPT_FOLDER}
. ./bind_port_for_QAT.sh

cd ${INSTALL_FOLDER}/${dpdk_pkg}
cd x86_64-native-linuxapp-icc
make test-build
echo cryptodev_qat_autotest > execute
summary=`./app/test -cf -n4 < execute`
tests_total=`echo "$summary" | grep "Tests Total" | awk '{print $5}'`
tests_skipped=`echo "$summary" | grep "Tests Skipped" | awk '{print $5}'`
tests_executed=`echo "$summary" | grep "Tests Executed" | awk '{print $5}'`
tests_unsupported=`echo "$summary" | grep "Tests Unsupported" | awk '{print $4}'`
tests_passed=`echo "$summary" | grep "Tests Passed" | awk '{print $5}'`
if [ "${tests_total}" == "${exp_tests_total}" ] && \
[ "${tests_skipped}" == "${exp_tests_skipped}" ] && \
[ "${tests_executed}" == "${exp_tests_executed}" ] && \
[ "${tests_unsupported}" == "${exp_tests_unsupported}" ] && \
[ "${tests_passed}" == "${ecp_tests_passed}" ];then
    logger "+ Test Suite Summary + Tests Total : ${tests_total} \
            + Tests Skipped : ${tests_skipped} \
            + Tests Executed : ${tests_executed} \
            + Tests Unsupported: ${tests_unsupported} \
            + Tests Passed : ${tests_passed} [PASS]"
    logger " Pass the cryptodev_qat_autotest test [PASS]"
else
    logger " Fail the cryptodev_qat_autotest test [FAIL]"
    ERROR=$(($ERROR+1))
fi

if [ "${ERROR}" == 0 ];then
	logger "${case} --check finished-- [PASS]"
else
	logger "${case} --check finished-- [FAIL]"
fi