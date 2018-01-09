#!/usr/bin/env bash

function show_error(){
    echo -e "\033[31m$1\033[0m"
}

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
            echo "New creating VM status is $status, waiting UP"
            break
        elif [ "$status" == "ERROR" ];then
            show_error "New creating VM status is $status"
            error_message=`echo "${vm_info}" |grep "| fault" |awk -F \| '{print $3}'`
            show_error "${error_message}"
            exit 1
        else
            echo "New creating VM status is $status, waiting ACTIVE"
        fi
    done
    export ip=`echo "$vm_info" |grep "ssh network" |awk -F \| '{print $3}' |sed 's/\s//g'`
#done


if [ "${ip}" == "" ] || [ "${case_shell}" == "" ];then
    show_error "ip: ${ip}"
    show_error "case script: ${case_shell}"
    exit 1
else
    echo "ip: ${ip}"
    echo "case script: ${case_shell}"
fi
cd ..
sleep 10

transfer_node=`neutron dhcp-agent-list-hosting-net ${SSH_NET} |grep True |head -n1 |awk '{print $4}'`
netns=qdhcp-`neutron  net-show ${SSH_NET} |egrep -w id |awk '{print $4}'`

AutoTest/scpcopy.exp ${transfer_node} ${netns} ${ip}  AutoTest ${case_shell}
