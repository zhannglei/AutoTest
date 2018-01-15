#!/usr/bin/env bash

# run under dpdk path

cp ${SCRIPT_FOLDER}/patch/*.patch .
patch -p 1 < *.patch

cp ${SCRIPT_FOLDER}/patch/l2fwd/main.c  examples/l2fwd/
# check whether network is virtio
lspci |grep "00:04.0 Eth" > /dev/null
if [ $? == 0 ];then
    echo "network is virtio will fix l3fwd main.c"
    cp ${SCRIPT_FOLDER}/patch/l3fwd/main.c  examples/l3fwd/
fi