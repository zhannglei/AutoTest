#!/usr/bin/env bash

# this script can only be used under this folder
# for example: . config.sh

#folder
export SCRIPT_FOLDER=${PWD}
export BASE_FOLDER=/root/APP
export SCRIPT_FOLDER=/root/AutoTest/Installation
export DPDK_FOLDER=${BASE_FOLDER}/Utilities/DPDK
export QAT_FOLDER=${BASE_FOLDER}/Drivers/QAT
export PKTGEN_FOLDER=${BASE_FOLDER}/Utilities/Pktgen
export GTEST_FOLDER=${BASE_FOLDER}/Configs/Preinstall_RPMs/Gtest
export INSTALL_FOLDER=~/BKC
[ ! -d ${INSTALL_FOLDER} ] && mkdir ${INSTALL_FOLDER}
export RPM_FOLDER=${BASE_FOLDER}/Configs/Preinstall_RPMs
export DPDK_FOLDER_FOR_PKTGEN=${RPM_FOLDER}/DPDK
export PATCH_FOR_DPDK_FOR_PKTGEN=${RPM_FOLDER}/patch
export PKTGEN_FOLDER=${RPM_FOLDER}/Pktgen
export LICENSE_FOLDER=${BASE_FOLDER}/ICC
export ICC_FOLDER=${BASE_FOLDER}/ICC
export I40E_FOLDER=${BASE_FOLDER}/Drivers/i40evf
export FLEXRAN_FOLDER=${BASE_FOLDER}/FlexRAN
export FLEXRAN_SRC=${INSTALL_FOLDER}/FlexRAN

#config_file
export ICC_CONFIG_FILE=/opt/intel/compilers_and_libraries/linux/bin/compilervars.sh
export ICC_VAR_FILE=/opt/intel/bin/iccvars.sh

#mac file
export MY_MAC_FILE=${SCRIPT_FOLDER}/my_mac.txt
export OTHER_MAC_FILE=${SCRIPT_FOLDER}/other_mac.txt

#cmd line
export TESTPMD_CMD="./testpmd -c 0xe -n 3 -- -i --nb-cores=2 --nb-ports=2 --eth-peer=0,\$mac1 --eth-peer=1,\$mac2"
