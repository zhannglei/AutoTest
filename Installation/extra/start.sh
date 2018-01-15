#!/usr/bin/env bash

#folder
export BASE_FOLDER=/root/APP
export SCRIPT_TAR_FOLDER=${BASE_FOLDER}/Configs/Preinstall_script
export SCRIPT_FOLDER=${BASE_FOLDER}/Configs/Preinstall_script/Auto_Installation

cd ${SCRIPT_TAR_FOLDER}

[ -d ${SCRIPT_FOLDER} ] || tar -xvf *.tar
cd ${SCRIPT_FOLDER}
. ./run.sh