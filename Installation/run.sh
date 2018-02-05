#!/usr/bin/env bash
cd $(dirname ${BASH_SOURCE[0]})
. ./config.sh
. ./common_fun.sh
if [[ ! $PATH =~ ${SCRIPT_FOLDER} ]];then
    PATH=$PATH:${SCRIPT_FOLDER}
    add_bashrc "PATH=$PATH:${SCRIPT_FOLDER}"
fi
    choose_info="
*****************************************
*    Wireless BKC Auto Installation     *
*****************************************

1. Install all drivers, utilities and BKC testing tools with required patches(step2-7)
2. Install RPM dependency Only
3. Install ICC with licenses Only
4. Install DPDK Only
5. Install PKTGEN Only
6. Install QAT Only
7. System configuration to update extlinux.conf
8. Presetting for test (Bind DPDK port, mount hugepage)
0. Exit
Input you choice:"

while [ 1 ]; do
    export ADD_PATCH=1
    read -p "$choose_info" choose
    stop_trap_signal
    case "$choose" in
        "0")
            break
            ;;
        "1")
            cd ${SCRIPT_FOLDER}
            . ./install_rpm.sh
            cd ${SCRIPT_FOLDER}
            . ./install_icc.sh
            cd ${SCRIPT_FOLDER}
            . ./install_dpdk.sh
            cd ${SCRIPT_FOLDER}
            . ./install_pktgen.sh
            cd ${SCRIPT_FOLDER}
            . ./install_qat.sh
            cd ${SCRIPT_FOLDER}
            . ./config_env.sh
            ;;
        "2")
            cd ${SCRIPT_FOLDER}
            . ./install_rpm.sh
            ;;
        "3")
            cd ${SCRIPT_FOLDER}
            . ./install_icc.sh
            ;;
        "4")
            cd ${SCRIPT_FOLDER}
            . ./install_dpdk.sh
            ;;
        "5")
            cd ${SCRIPT_FOLDER}
            . ./install_pktgen.sh
            ;;
        "6")
            cd ${SCRIPT_FOLDER}
            . ./install_qat.sh
            ;;
        "7")
            cd ${SCRIPT_FOLDER}
            . ./config_env.sh
            ;;
        "8")
            cd ${SCRIPT_FOLDER}
            . ./bind_port.sh
            ;;
        "*")
            echo "Your choose is not match, please try again."
    esac
    start_trap_signal
done
