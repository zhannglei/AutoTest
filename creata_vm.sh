#!/usr/bin/env bash


while getopts "c:" arg;do
    case ${arg} in
        c)
            config=${OPTARG}
            ;;
        ?)
            echo "arg not found"
            exit 1
            ;;
    esac
done
if [ ! -f "${config}" ];then
    echo  "case not found"
    exit 1
fi

source /etc/nova/openrc
source ${config}
cd $(dirname ${BASH_SOURCE[0]})
DATE=`date "+%Y%m%d-%H%M%S"`
if [ "${case_shell}" != "" ];then
    case=`basename ${case_shell} .sh`
    LOGFILE=${case}_${DATE}.log
    sed -i "/^${case} /d" tmp
    echo "$case ${LOGFILE}" >> tmp
fi
LOGFILE_PATH=~/log/control/${LOGFILE}
source case/common.sh

SSH_NET=ssh
P0_NET=A-P0
P1_NET=A-P1

# neutron dhcp-agent-list-hosting-net ssh
# neutron  net-show

nodes=$(nova hypervisor-list |grep enabled |awk '{print $4}')
for node in ${nodes};do
    tmp=$(nova hypervisor-show ${node})
done

image_id=$(glance image-list |egrep "\s${image_name}\s" |awk '{print $2}')

# virtio pci-sriov
cmd="nova boot --flavor=${flavor} \
--nic net-name=${SSH_NET} \
--nic net-name=${P0_NET},vif-model=${vif_model} \
--nic net-name=${P1_NET},vif-model=${vif_model} \
--image ${image_id} ${vm_name} "

#cmd="$cmd --availability-zone nova:wfq-1"
#if [ "${vms}" == "1" ];then
#    cmds=("${cmd}")
#elif [ "${vms}" == "2" ];then
#    if [ "${hosts}" == "1" ];then
#        echo "This config not completed"
#    elif [ "${hosts}" == "2" ];then
#        cmd1="$cmd --availability-zone nova:wfq-0"
#        cmd2="$cmd --availability-zone nova:wfq-1"
#        cmds=("${cmd1}" "${cmd2}")
#    fi
#fi
#for ((i=0;i<${#cmds[*]};i++));do
    # create VMs
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
    export ip=`echo "$vm_info" |grep "ssh network" |awk -F \| '{print $3}' |sed 's/\s//g'`
#done

logger "ip: ${ip} [DEBUG]"
logger "case script: ${case_shell} [DEBUG]"
if [ "${ip}" == "" ];then
    logger "Create VM [FAIL]"
    exit 1
else
    logger "Create VM [PASS]"
fi

cd ..
if [ "${time_delay}" == "" ];then
    time_delay=10
fi
sleep_seconds "Please wait VM up" ${time_delay}

transfer_node=`neutron dhcp-agent-list-hosting-net ${SSH_NET} |grep True |head -n1 |awk '{print $4}'`
netns=qdhcp-`neutron  net-show ${SSH_NET} |egrep -w id |awk '{print $4}'`

[ ! -d ~/log/control ] && mkdir -p ~/log/control
[ ! -d ~/log/case ] && mkdir -p ~/log/case

#copy package to VM
for file in ${files};do
    AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  ${file} |tee -a ${LOGFILE_PATH}
done

#copy AutoTest script to VM
AutoTest/scp_in.exp ${transfer_node} ${netns} ${ip}  AutoTest ${case_shell} |tee -a ${LOGFILE_PATH}

#copy log file out
sleep 3
AutoTest/scp_out.exp ${transfer_node} ${netns} ${ip} ${LOGFILE} |tee -a ${LOGFILE_PATH}
