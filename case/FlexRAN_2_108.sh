#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

. ../config/FlexRAN_2_108.ini
. ./common.sh

ERROR=0

cd ../Installation

. ./config.sh
. ./common_fun.sh
cd ${SCRIPT_FOLDER}
. ./install_rpm.sh
cd ${SCRIPT_FOLDER}
. ./install_icc.sh
cd ${SCRIPT_FOLDER}
. ./install_dpdk.sh
cd ${SCRIPT_FOLDER}
. ./install_flexran.sh

. ~/.bashrc

cmds=("run 2 108" "run 2 208" "run 2 308" "run 2 408" "run 2 608" "run 2 118" "run 2 218" "run 2 318" "run 2 418" "run 2 618")
i=0
log=${FLEXRAN_SRC}/bin/lte/l1/l1_mlog_stats.txt
tmp=~/tmp
rm $tmp
while [ $i -lt ${#cmds[*]} ]; do
    cmd=${cmds[i]}
    x=
    y=
    z=
    for t in 1 2 3;do
        rm $log
        cd ${FLEXRAN_SRC}/bin/lte/l1
        ~/AutoTest/tools/l1.exp &
        sleep 10
        cd ${FLEXRAN_SRC}/bin/lte/testmac
        ~/AutoTest/tools/l2.exp "$cmd"
        kill -9 $(ps -ef |grep -E 'testmac|l1app|l1.exp'  |awk '{print $2}')
        logger "$cmd $t time result \r`cat $log` [INFO]"
        value=`cat $log |grep "Total DL + UL (Per Cell)" |awk -F \: '{print $2}' |sed 's/\s//g' |head -n 1`
        if [ $t -eq 1 ];then
            x=$value
        elif [ $t -eq 2 ];then
            y=$value
        else
            z=$value
        fi
        sleep 3
    done
    ave=`awk -v x=${x} -v y=${y} -v z=${z} 'BEGIN{printf "%.2f\n",(x+y+z)/3}'`
        echo "$cmd:$x, $y, $z, $ave" >> $tmp
    i=$((i+1))
done

logger "Test case summary result \r`cat ${tmp}`"


if [ "${ERROR}" == 0 ];then
    logger "${case} --check finished-- [PASS]"
else
    logger "${case} --check finished-- [FAIL]"
fi
