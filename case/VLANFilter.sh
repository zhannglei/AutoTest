#!/usr/bin/env bash

. ./common.sh

ERROR=0
cat tmp/$case

if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi