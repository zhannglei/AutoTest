#!/usr/bin/env bash
. ./config.sh

function rpm_install(){
    rpm -q $2 >/dev/null && echo "$2.rpm installed " || rpm $1 $2.rpm
}

cd ${RPM_FOLDER}
rpm_tar=`ls -F |grep "[^/]$"`
gcc_rpm_folder=`ls -F |grep -i "ICC.*/$"`
qat_rpm_folder=`ls -F |grep -i "QAT.*/$"`
gtest_rpm_folder=`ls -F |grep -i "GTEST_RPM.*/$"`
if [ "${gcc_rpm_folder}" == "" ] || [ "${qat_rpm_folder}" == "" ];then
    tar -xvf ${rpm_tar}
    gcc_rpm_folder=`ls -F |grep -i "ICC.*/$"`
    qat_rpm_folder=`ls -F |grep -i "QAT.*/$"`
    gtest_rpm_folder=`ls -F |grep -i "GTEST_RPM.*/$"`
fi
cd ${gcc_rpm_folder}

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

cd ..
cd ${gtest_rpm_folder}
rpm_install -i perl-Error-0.17020-2.el7.noarch
rpm_install -i perl-TermReadKey-2.30-20.el7.x86_64
rpm -U perl-Git-1.8.3.1-12.el7_4.noarch.rpm git-1.8.3.1-12.el7_4.x86_64.rpm libgnome-keyring-3.12.0-1.el7.x86_64.rpm
rpm_install -i numactl-2.0.9-6.el7_2.x86_64
rpm -U cmake-2.8.12.2-2.el7.x86_64.rpm libarchive-3.1.2-10.el7_2.x86_64.rpm
rpm_install -i gdb-7.6.1-100.el7.x86_64
rpm_install -i dstat-0.7.2-12.el7.noarch
rpm -U vim-common-7.4.160-2.el7.x86_64.rpm vim-enhanced-7.4.160-2.el7.x86_64.rpm vim-filesystem-7.4.160-2.el7.x86_64.rpm gpm-libs-1.20.7-5.el7.x86_64.rpm
rpm_install -i mlocate-0.26-6.el7.x86_64

cd ..
cd ${qat_rpm_folder}
rpm_install -i systemd-devel-219-19.el7_2.13.tis.1.x86_64
rpm_install -i libicu-50.1.2-15.el7.x86_64
rpm_install -i boost-atomic-1.53.0-27.el7.x86_64
rpm_install -i boost-system-1.53.0-27.el7.x86_64
rpm_install -i boost-chrono-1.53.0-27.el7.x86_64
rpm_install -i boost-context-1.53.0-27.el7.x86_64
rpm_install -i boost-date-time-1.53.0-27.el7.x86_64
rpm_install -i boost-filesystem-1.53.0-27.el7.x86_64
rpm_install -i boost-iostreams-1.53.0-27.el7.x86_64
rpm_install -i boost-math-1.53.0-27.el7.x86_64
rpm_install -i boost-program-options-1.53.0-27.el7.x86_64
rpm_install -i boost-python-1.53.0-27.el7.x86_64
rpm_install -i boost-random-1.53.0-27.el7.x86_64
rpm_install -i boost-serialization-1.53.0-27.el7.x86_64
rpm_install -i boost-signals-1.53.0-27.el7.x86_64
rpm_install -i boost-test-1.53.0-27.el7.x86_64
rpm_install -i boost-thread-1.53.0-27.el7.x86_64
rpm_install -i boost-timer-1.53.0-27.el7.x86_64
rpm_install -i boost-wave-1.53.0-27.el7.x86_64
rpm_install -i boost-regex-1.53.0-27.el7.x86_64
rpm_install -i boost-graph-1.53.0-27.el7.x86_64
rpm_install -i boost-locale-1.53.0-27.el7.x86_64

rpm_install -i boost-1.53.0-27.el7.x86_64
rpm_install -i boost-devel-1.53.0-27.el7.x86_64
rpm_install -i zlib-devel-1.2.7-15.el7.x86_64
rpm_install -i libsepol-devel-2.1.9-3.el7.x86_64
rpm_install -i pcre-devel-8.32-15.el7_2.1.x86_64
rpm_install -i libselinux-devel-2.2.2-6.el7.x86_64
rpm_install -i keyutils-libs-devel-1.5.8-3.el7.x86_64
rpm_install -i libcom_err-devel-1.42.9-7.el7.x86_64
rpm_install -i libverto-devel-0.2.5-4.el7.x86_64
rpm_install -i krb5-devel-1.13.2-12.el7_2.x86_64
rpm_install -i openssl-devel-1.0.1e-51.el7_2.7.x86_64
cd ${SCRIPT_FOLDER}
. ./install_gtest.sh