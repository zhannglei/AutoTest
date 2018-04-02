#!/usr/bin/env bash
function show_error(){
    echo -e "\033[31m$1\033[0m"
}

usage="usage: ./testCase -c <config file path>
example: ./testCase -c config/vMemory_MemInfo.ini"
while getopts "c:" arg;do
    case ${arg} in
        c)
            config=${OPTARG}
            ;;
        ?)
            echo "arg not found"
            echo "${usage}"
            exit 1
            ;;
    esac
done
if [ ! -f "${config}" ];then
    show_error  "case config "${config}" is not found"
    echo "${usage}"
    exit 1
fi
if [ "${config##*.}" != "ini" ];then
    show_error  "case config "${config}" is not correct"
    echo "${usage}"
    exit 1
fi

source /etc/nova/openrc
source ${config}
cd $(dirname ${BASH_SOURCE[0]})
DT=`date "+%Y%m%d-%H%M%S"`
case=`basename ${case_shell} .sh`
TMPFILE=tmp/$case
[ -f ${TMPFILE} ] && rm ${TMPFILE}
LOGFILE=${case}_${DT}.log

LOGFILE_PATH=~/log/control/${LOGFILE}
source case/common.sh

SSH_NET=ssh
P0_NET=A-P0
P1_NET=A-P1

# neutron dhcp-agent-list-hosting-net ssh
# neutron  net-show

node_vm_info=""
rpm -q jq-1.5-1.el7.x86_64 > /dev/null || echo "Intel@123" | sudo -S rpm -i Installation/rpm/oniguruma-5.9.5-3.el7.x86_64.rpm
rpm -q jq-1.5-1.el7.x86_64 > /dev/null || echo "Intel@123" | sudo -S rpm -i Installation/rpm/jq-1.5-1.el7.x86_64.rpm
sleep 3
nodes=$(nova hypervisor-list |grep enabled |awk '{print $4}')
for node in ${nodes};do
    tmp=$(nova hypervisor-show ${node})
    total=`echo "${tmp}" |grep -w vcpus_node |awk -F \| '{print $3}' |jq '.["0"]'`
    used=`echo "${tmp}" |grep -w vcpus_used |awk '{print $4}' |awk -F \. '{print $1}'`
    can_vms=$(($(($total-$used))/4))
    node_vm_info=$node_vm_info" $node|$can_vms"
done

image_id=$(glance image-list |egrep -i "\s${image_name}\s" |awk '{print $2}')

# virtio pci-sriov
cmd="nova boot --flavor=${flavor} \
--nic net-name=${SSH_NET} \
--nic net-name=${P0_NET},vif-model=${vif_model} \
--nic net-name=${P1_NET},vif-model=${vif_model} \
--image ${image_id} "

declare -a cmds
if [ "${vms}" == "1" ];then
    cmds[${#cmds[*]}]="${cmd} ${vm_name}"
elif [ "${vms}" == "2" ];then
    for i in  $node_vm_info; do
        nod=`echo "$i" |awk -F\| '{print $1}'`
        unused_vms=`echo "$i" |awk -F\| '{print $2}'`
        if [ "${hosts}" == "1" ];then
            if [[ ${unused_vms} -ge ${vms} ]];then
                while [[ ${#cmds[*]} -lt ${vms} ]];do
                    cmds[${#cmds[*]}]="$cmd ${vm_name}_${#cmds[*]} --availability-zone nova:${nod}"
                done
            fi
        elif [ "${hosts}" == "2" ];then
            if [[ ${unused_vms} -ge 1 ]];then
                cmds[${#cmds[*]}]="$cmd ${vm_name}_${nod} --availability-zone nova:${nod}"
                if [[ ${#cmds[*]} -ge ${vms} ]];then
                    break
                fi
            fi
        fi
    done
    if [[ ${#cmds[*]} -lt ${vms} ]];then
        echo "not enough hosts found"
        exit 1
    fi
fi

for ((i=0;i<${#cmds[*]};i++));do
    # create VMs
    cmd=${cmds[i]}
    tmp=`eval ${cmd}`
    vm_id=`echo "${tmp}"|egrep "\bid\b" |awk -F \| '{print $3}'|sed 's/\s//g'`
    sleep 2
    while [ 1 ];do
        sleep 3
        vm_info=`nova show $vm_id`
        status=`echo "$vm_info" |egrep -w "status" |awk -F \| '{print $3}'|sed 's/\s//g'`
        if [ "$status" == "ACTIVE" ];then
            logger "New creating VM status is $status, waiting UP [DEBUG]"
            break
        elif [ "$status" == "ERROR" ] || [ "$status" == "" ];then
            logger "New creating VM status is $status [FAIL]"
            error_message=`echo "${vm_info}" |grep "| fault" |awk -F \| '{print $3}'`
            logger "${error_message} [FAIL]"
            exit 1
        else
            logger "New creating VM status is $status, waiting ACTIVE [DEBUG]"
        fi
    done
    sleep 5
    SSH_IP=`echo "$vm_info" |grep "${SSH_NET} network" |awk -F \| '{print $3}' |sed 's/\s//g'`
    SSH_MAC=`echo "$vm_info" |grep "\"${SSH_NET}\""|awk -F \| '{print $3}' |jq '.nic1.mac_address' |sed s/\"//g`
    P0_IP=`echo "$vm_info" |grep "${P0_NET} network" |awk -F \| '{print $3}' |sed 's/\s//g'`
    P0_MAC=`echo "$vm_info" |grep "\"${P0_NET}\""|awk -F \| '{print $3}' |jq '.nic2.mac_address' |sed s/\"//g`
    P1_IP=`echo "$vm_info" |grep "${P1_NET} network" |awk -F \| '{print $3}' |sed 's/\s//g'`
    P1_MAC=`echo "$vm_info" |grep "\"${P1_NET}\""|awk -F \| '{print $3}' |jq '.nic3.mac_address' |sed s/\"//g`
    if [ "${SSH_NET}" == "" ];then
        logger "Create VM [FAIL]"
        exit 1
    else
        logger "Create VM [PASS]"
    fi
    LOGFILE=${case}_${DT}_${i}.LOG
    echo "COUNT=${i} SSH_IP=${SSH_IP} SSH_MAC=${SSH_MAC} \
    P0_IP=${P0_IP} P0_MAC=${P0_MAC} \
    P1_IP=${P1_IP} P1_MAC=${P1_MAC} \
    LOGFILE=${LOGFILE} " >> ${TMPFILE}

done

logger "`cat ${TMPFILE}` [DEBUG]"
cd ..
if [ "${time_delay}" == "" ];then
    time_delay=10
fi
sleep_seconds "Please wait VM up" ${time_delay}

transfer_node=`neutron dhcp-agent-list-hosting-net ${SSH_NET} |grep True |head -n1 |awk '{print $4}'`
netns=qdhcp-`neutron  net-show ${SSH_NET} |egrep -w id |awk '{print $4}'`

[ ! -d ~/log/control ] && mkdir -p ~/log/control
[ ! -d ~/log/case ] && mkdir -p ~/log/case

while read line;do
    ip=`echo ${line} |sed 's/ /\n/g' |grep '^SSH_IP=' |awk -F \= '{print $2}'`
    LOGFILE=`echo ${line} |sed 's/ /\n/g' |grep '^LOGFILE=' |awk -F \= '{print $2}'`
    #copy package to VM
    for file in ${files};do
        logger "AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  ${file} [DEBUG]"
        AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  ${file} |tee -a ${LOGFILE_PATH}
        sleep 2
    done

    #copy AutoTest script to VM
    logger "AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  AutoTest ${case_shell} [DEBUG]"
    AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  AutoTest ${case_shell} |tee -a ${LOGFILE_PATH}


    #copy log file out
    sleep 3
    logger "AutoTest/scp_out.exp ${transfer_node} ${netns} ${ip} ${LOGFILE} [DEBUG]"
    AutoTest/scp_out.exp ${transfer_node} ${netns} ${ip} ${LOGFILE} |tee -a ${LOGFILE_PATH}
done < AutoTest/${TMPFILE}