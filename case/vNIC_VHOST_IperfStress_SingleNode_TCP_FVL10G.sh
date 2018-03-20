#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ./common.sh
. ../config/vNIC_VHOST_IperfStress_SingleNode_TCP_FVL10G.ini

. ./IperfStress.sh


