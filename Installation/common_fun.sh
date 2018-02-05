. ./config.sh
function mount_huge(){
    [ ! -d /mnt/huge ] && mkdir -p /mnt/huge
    add_bashrc "mkdir -p /mnt/huge"
    add_bashrc "mount -t hugetlbfs nodev /mnt/huge"
    mount |grep /mnt/huge >/dev/null ||  mount -t hugetlbfs nodev /mnt/huge
    [ $? == 0 ] && echo "mount huge ok"
    echo 2048 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
    add_bashrc "echo 2048 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
}

function add_bashrc(){
    str=$1
    grep "$str" /root/.bashrc > /dev/null
    if [ $? != 0 ];then
        echo "$str" >> /root/.bashrc
    fi
}
function get_mac_address(){
#get mac address
    eths=`ifconfig -a |egrep ^e.*flags= |grep -v eth0 |awk -F : '{print $1}'`
    my_mac=""
    for eth in $eths; do
        net=`ethtool -i $eth |grep driver |awk '{print $2}'`
        mac=`ifconfig $eth |grep ether |awk '{print $2}'`
        my_mac="$my_mac $mac"
    done
    echo $my_mac
}

function bind_dpdk(){
    DPDK_BIND_TOOL=$1
    #bind dpdk
    eth_ids=`$DPDK_BIND_TOOL --status |egrep -i "network devices using kernel" -A4 |grep "^0000:00:0[4|5|6]" |awk '{print $1}'`
    for eth_id in $eth_ids; do
        $DPDK_BIND_TOOL -b igb_uio $eth_id
        [ $? == "0" ] && echo "bind $eth_id success" || echo "bind $eth_id fail"
    done
}

function check_rpm(){
    rpms="gcc-c++-4.8.5-16.el7.x86_64
    kernel-devel-3.10.0-693.el7.x86_64
    libhugetlbfs-devel-2.16-12.el7.x86_64"
    for rpm in ${rpms};do
        rpm -q $rpm >> /dev/null
        if [ $? != 0 ];then
            echo "$rpm not installed"
            return 1
        fi
    done
    return 0
}

function check_rpm_and_install(){
    check_rpm
    if [ $? != 0 ];then
       . ./install_rpm.sh
    fi
}

function check_icc_and_install(){
    cd ${SCRIPT_FOLDER}
    [ -f ${ICC_CONFIG_FILE} ] && source  ${ICC_CONFIG_FILE} intel64
    icc -v &> /dev/null
    if [ $? != 0 ];then
        read -p "ICC has not been installed, do you want to install ICC, default y [y/n]:" answer
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "" ];then
            . ./install_icc.sh
        fi
    fi
    cd ${SCRIPT_FOLDER}
}

function check_dpdk_and_install(){
    cd ${SCRIPT_FOLDER}
    find ${INSTALL_FOLDER} -name igb_uio.ko |grep igb_uio.ko
    if [ $? != "0" ];then
        read -p "DPDK has not been installed, do you want to install DPDK, default y [y/n]" answer
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "" ];then
            . ./install_dpdk.sh
        else
            exit 1
        fi
    fi
}

function stop_trap_signal(){
    trap "" 2 3
}

function start_trap_signal(){
    trap 2 3

}