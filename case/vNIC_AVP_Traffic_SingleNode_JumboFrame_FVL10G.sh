#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ./common.sh
. ../config/vNIC_AVP_Traffic_SingleNode_JumboFrame_FVL10G.ini

. ./JumboFrame.sh

