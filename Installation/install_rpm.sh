#!/usr/bin/env bash
. ./config.sh

function rpm_install(){
    rpm -q $2 >/dev/null && echo "$2.rpm installed " || rpm $1 $2.rpm
}

cd ${RPM_FOLDER}
rpm_tar=`ls -F |grep "[^/]$"`
rpm_folder=`ls -F |grep "/$"`
[ "${rpm_folder}" == "" ] && tar -xvf ${rpm_tar}
rpm_folder=`ls -F |grep "/$"`
cd ${rpm_folder}

rpm_install -i tcl-8.5.13-8.el7.x86_64
rpm_install -i expect-5.45-14.el7_1.x86_64
rpm_install -U libgomp-4.8.5-16.el7.x86_64
rpm_install -U libgcc-4.8.5-16.el7_4.1.x86_64
rpm_install -i cpp-4.8.5-16.el7.x86_64
rpm_install -i gcc-4.8.5-16.el7.x86_64
rpm -U libstdc++-4.8.5-16.el7.x86_64.rpm libstdc++-devel-4.8.5-16.el7.x86_64.rpm
rpm_install -i gcc-c++-4.8.5-16.el7.x86_64
rpm_install -i kernel-devel-3.10.0-693.el7.x86_64
rpm_install -i libhugetlbfs-2.16-12.el7.x86_64
rpm_install -i libhugetlbfs-devel-2.16-12.el7.x86_64

rpm_install -i libpcap-devel-1.5.3-8.el7.x86_64
rpm_install -i numactl-devel-2.0.9-6.el7_2.x86_64
rpm_install -i expect-5.45-14.el7_1.x86_64
