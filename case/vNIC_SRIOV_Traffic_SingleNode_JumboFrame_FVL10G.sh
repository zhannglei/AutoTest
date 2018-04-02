#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ./common.sh
. ../config/vNIC_SRIOV_Traffic_SingleNode_JumboFrame_FVL10G.ini

. ./JumboFrame.sh

