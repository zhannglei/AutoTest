#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/vNIC_AVP_DriverReset_AVS_FVL10G.ini

. DriverReset.sh
