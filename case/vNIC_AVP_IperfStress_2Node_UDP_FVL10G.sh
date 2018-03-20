#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ./common.sh
. ../config/vNIC_AVP_IperfStress_2Node_UDP_FVL10G.ini

. ./IperfStress.sh


