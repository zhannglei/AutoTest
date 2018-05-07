#!/bin/bash


CPU_FEATURES_DETECT_AVX512=`cat /proc/cpuinfo | grep avx512 | wc -l`
CPU_FEATURES_DETECT_AVX2=`cat /proc/cpuinfo | grep avx2 | grep f16c | grep fma | grep bmi | wc -l`
CPU_FEATURES_DETECT_SSE4_2=`cat /proc/cpuinfo | grep sse4_2 | wc -l`

 if [ $CPU_FEATURES_DETECT_AVX512 -ne 0 ]
   then
        export ISA=avx512
    elif [ $CPU_FEATURES_DETECT_AVX2 -ne 0 ]
    then
        export ISA=avx2
    elif [ $CPU_FEATURES_DETECT_SSE4_2 -ne 0 ]
    then
        export ISA=sse4_2
 fi

BASE=$PWD
export DIR_WIRELESS_FW=$BASE/framework/
add_bashrc "export DIR_WIRELESS_FW=$BASE/framework/"
export DIR_WIRELESS_SDK=$BASE/sdk/build-$ISA-icc
add_bashrc "export DIR_WIRELESS_SDK=$BASE/sdk/build-$ISA-icc"
export RTE_TARGET=x86_64-native-linuxapp-icc
add_bashrc "export RTE_TARGET=x86_64-native-linuxapp-icc"
#export GTEST_ROOT=/opt/gtest/gtest-1.7.0/
###2117-Q3####
#export RTE_SDK=/root/dpdk-16.11
###2117-Q4####
#export RTE_SDK=/root/dpdk-17.11
#############


cd $BASE/ferrybridge/lib/; make clean; make
cd $BASE/wls_mod/;       chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/wls_libs/mlog/; chmod +x build.sh; ./build.sh clean; ./build.sh

###############SDK compile#######################
cd $BASE/sdk/;unset DESTDIR
cd $BASE/sdk/; chmod +x create-makefiles-linux.sh; ./create-makefiles-linux.sh
cd $BASE/sdk/build-$ISA-icc/; make install

##############FrameWork compile##################
cd $BASE/framework/bbupool/; make clean;make


###########RefStack compile######################
cd $BASE/build/testapp/linux/  ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/build/testmac/ ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/build/testue/  ;   chmod +x build.sh; ./build.sh xclean; ./build.sh
cd $BASE/build/l1app/   ;   chmod +x build.sh; ./build.sh xclean; ./build.sh

