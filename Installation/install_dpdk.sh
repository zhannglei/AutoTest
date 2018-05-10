#!/usr/bin/env bash

. ./config.sh
. ./common_fun.sh

check_icc_and_install

cd ${DPDK_FOLDER}
dpdk_pkg=`ls -F ${INSTALL_FOLDER} |grep dpdk.*/$`
dpdk_tar=`ls -F |grep dpdk.*[^/]$`
[ "$dpdk_pkg" == "" ] && tar -xvf $dpdk_tar -C ${INSTALL_FOLDER}
dpdk_pkg=`ls -F ${INSTALL_FOLDER} |grep "dpdk.*/$"`
export RTE_SDK=${INSTALL_FOLDER}/${dpdk_pkg}
add_bashrc "export RTE_SDK=${INSTALL_FOLDER}/${dpdk_pkg}"
export RTE_TARGET=x86_64-native-linuxapp-icc
add_bashrc "export RTE_TARGET=x86_64-native-linuxapp-icc"

cd ${INSTALL_FOLDER}
cd ${dpdk_pkg}

lspci |grep 37c9 && sed -i 's/CONFIG_RTE_LIBRTE_PMD_QAT=n/CONFIG_RTE_LIBRTE_PMD_QAT=y/g' config/common_base

if [ -f x86_64-native-linuxapp-icc/app/testpmd ];then
    echo "DPDK has already installed."
else

    rpm -q numactl-devel-2.0.9-6.el7_2.x86_64
    if [ $? != 0 ];then
        echo "numactl is not installed."
        exit 1
    fi

    # only for patch
    if [ ${ADD_PATCH} == 1 ];then
        . ${SCRIPT_FOLDER}/add_patch.sh
    fi
    make install T=x86_64-native-linuxapp-icc
    if [ -f x86_64-native-linuxapp-icc/app/testpmd ];then
        echo "DPDK is installed successfully."
    else
        echo "DPDK is installed failed."
        exit 1
    fi
fi
modprobe uio
lsmod |grep igb_uio >> /dev/null || insmod x86_64-native-linuxapp-icc/kmod/igb_uio.ko

cd ${INSTALL_FOLDER}/${dpdk_pkg}examples/l3fwd
if [ -f build/l3fwd ];then
    echo "l3fwd has already installed."
else
    make
    if [ -f build/l3fwd ];then
        echo "l3fwd is installed successfully."
    else
        echo "l3fwd is installed failed."
        exit 1
    fi
fi

#cd ${INSTALL_FOLDER}/${dpdk_pkg}examples/l2fwd
#if [ -f build/l2fwd ];then
#    echo "l2fwd has already installed."
#else
#    make
#    if [ -f build/l2fwd ];then
#        echo "l2fwd is installed successfully."
#    else
#        echo "l2fwd is installed failed."
#        exit 1
#    fi
#fi

cd ${INSTALL_FOLDER}/${dpdk_pkg}examples/l2fwd-crypto
if [ -f build/l2fwd-crypto ];then
    echo "l2fwd-crypto has already installed."
else
    make
    if [ -f build/l2fwd-crypto ];then
        echo "l2fwd-crypto is installed successfully."
    else
        echo "l2fwd-crypto is installed failed."
        exit 1
    fi
fi

#mount_huge