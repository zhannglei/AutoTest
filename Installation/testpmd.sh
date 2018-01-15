#!/usr/bin/env bash
. ./config.sh

if [ -f "${MY_MAC_FILE}" ];then
echo ""
fi

cd ${DPDK_FOLDER}/x86_64-native-linuxapp-icc/app/
${SCRIPT_FOLDER}/testpmd.exp ${TESTPMD_CMD} $mac1 $mac2

