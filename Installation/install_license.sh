#!/usr/bin/env bash
. ./config.sh

cd ${LICENSE_FOLDER}
mkdir -p /opt/intel/licenses
ls *.lic
if [ $? == 0 ];then
    cp *.lic  /opt/intel/licenses/
else
    echo "not find licence file"
    exit 1
fi
cd -