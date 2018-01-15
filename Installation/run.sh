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

1. Install all packages and configure BKC environment (RPM dependency, ICC with licenses, DPDK, PKTGEN, extlinux.conf)
2. Install RPM dependency Only
3. Install ICC with licenses Only
4. Install DPDK Only
5. Install PKTGEN Only
6. System configuration to update extlinux.conf
7. ONLY FOR BKC TESTING, install all packages and configure BKC environment with special patches
8. Presetting for test (Bind DPDK port, mount hugepage)
0. Exit
Input you choice:"

while [ 1 ]; do
    export ADD_PATCH=0
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
            . ./config_env.sh
            ;;
        "8")
            cd ${SCRIPT_FOLDER}
            . ./bind_port.sh
            ;;
        "7")
            export ADD_PATCH=1
            cd ${SCRIPT_FOLDER}
            . ./install_rpm.sh
            cd ${SCRIPT_FOLDER}
            . ./install_icc.sh
            cd ${SCRIPT_FOLDER}
            . ./install_dpdk.sh
            cd ${SCRIPT_FOLDER}
            . ./install_pktgen.sh
            cd ${SCRIPT_FOLDER}
            . ./config_env.sh
            ;;
        "*")
            echo "Your choose is not match, please try again."
    esac
    start_trap_signal
done
