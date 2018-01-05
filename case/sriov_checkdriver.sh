#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})
. ../config/sriov_checkdriver.ini

. ./checkdriver.sh
