#!/usr/bin/env bash

. ./config.sh
. ./common_fun.sh

check_dpdk_and_install
processor=`cat /proc/cpuinfo  |grep -c  processor`
if [ $processor -lt 12 ];then
    echo "cpu count is $processor, please check"
    break
fi

hugepages=`cat /proc/meminfo  |grep -i hugepages_total |awk '{print $2}'`
if [ "$hugepages" -lt 10 ];then
    echo "hugepages is $hugepages, please check"
    break
fi

cd ${FLEXRAN_FOLDER}
mkdir -p ${FLEXRAN_SRC}

flexran_pkg=`ls ${FLEXRAN_FOLDER} |grep -i flexran`
tar -xvf ${flexran_pkg} -C ${FLEXRAN_SRC}

cd ${FLEXRAN_SRC}

sed -i '/echo -n /d' ./extract.sh
sed -i '/read install_path/d' ./extract.sh
sed -i '/more Intel_OBL_Software_Clickwrap_License.txt/d' ./*.sh

# extract
. ${SCRIPT_FOLDER}/flexran/auto_extract.sh

# build
#CPU_FEATURES_DETECT_AVX512=`cat /proc/cpuinfo | grep avx512 | wc -l`
#CPU_FEATURES_DETECT_AVX2=`cat /proc/cpuinfo | grep avx2 | grep f16c | grep fma | grep bmi | wc -l`
#CPU_FEATURES_DETECT_SSE4_2=`cat /proc/cpuinfo | grep sse4_2 | wc -l`
#
# if [ $CPU_FEATURES_DETECT_AVX512 -ne 0 ]
#   then
#        export ISA=avx512
#    elif [ $CPU_FEATURES_DETECT_AVX2 -ne 0 ]
#    then
#        export ISA=avx2
#    elif [ $CPU_FEATURES_DETECT_SSE4_2 -ne 0 ]
#    then
#        export ISA=sse4_2
# fi

BASE=${FLEXRAN_SRC}
export DIR_WIRELESS_FW=${BASE}/framework
add_bashrc "export DIR_WIRELESS_FW=${BASE}/framework"
export DIR_WIRELESS_SDK_ROOT=${BASE}/sdk
add_bashrc "export DIR_WIRELESS_SDK_ROOT=${BASE}/sdk"
export WIRELESS_SDK_TARGET_ISA=avx512
add_bashrc "export WIRELESS_SDK_TARGET_ISA=avx512"
export SDK_BUILD=build-avx512-icc
add_bashrc "export SDK_BUILD=build-avx512-icc"
export DIR_WIRELESS_SDK=${DIR_WIRELESS_SDK_ROOT}/${SDK_BUILD}
add_bashrc "export DIR_WIRELESS_SDK=${DIR_WIRELESS_SDK_ROOT}/${SDK_BUILD}"
export DIR_WIRELESS_TEST_4G=~/BKC/FlexRAN/tests/lte
add_bashrc " export DIR_WIRELESS_TEST_4G=~/BKC/FlexRAN/tests/lte"
export RTE_TARGET=x86_64-native-linuxapp-icc
add_bashrc "export RTE_TARGET=x86_64-native-linuxapp-icc"

cd $BASE/ferrybridge/lib/; make clean; make
cd $BASE/wls_mod/;       chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/wls_libs/mlog/; chmod +x build.sh; ./build.sh clean; ./build.sh

###############SDK compile#######################
cd $BASE/sdk/;unset DESTDIR
cd $BASE/sdk/; chmod +x create-makefiles-linux.sh; ./create-makefiles-linux.sh
cd $BASE/sdk/build-avx512-icc/; make install

##############FrameWork compile##################
cd $BASE/framework/bbupool/; make clean;make


###########build testapp#########################
cd $BASE/build/lte/testapp/linux/  ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
###########build testmac#########################
cd $BASE/build/lte/testmac/ ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/build/lte/testue/  ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/build/lte/l1app/   ;   chmod +x build.sh; ./build.sh xclean; ./build.sh


sleep 2

#cd ${FLEXRAN_SRC}
#${SCRIPT_FOLDER}/flexran/create_re_bin.sh

