#!/usr/bin/env bash

cd $(dirname ${BASH_SOURCE[0]})

diff Installation/extlinux.conf /boot/extlinux.conf > /dev/null
if [ $? != 0 ];then
    if [[ "$HOSTNAME" =~ "192" ]];then
        cp Installation/extlinux.conf /boot/extlinux.conf -f
        echo "dhclient"  >> /etc/rc.d/rc.local
        echo "boot config check fail, will reboot"
        sleep 2 && reboot &
    fi
else
    echo "boot config check pass"
fi