#!/bin/bash


echo "create lte_phy"
find ./lte_phy/ -type f  ! -name "l1.sh" -type f  ! -name "l1app"  -type f  ! -name "phycfg_timer.xml" -exec rm {} \;
  sleep 1
  
for i in  ./lte_phy/*
do
  echo "$i"
  if [ -d $i ]
  then
    rm -rf $i
  fi
done


echo "create lte_testmac"
find ./lte_testmac/ -type f  ! -name "l2.sh" -type f  ! -name "testmac"  -type f  ! -name "tests.cfg"  -type f  ! -name "tests_customer.cfg" -type f  ! -name "testmac_cfg.xml" -exec rm {} \;
  sleep 1

echo "create wls_mod"
find ./wls_mod/ -type f  ! -name "libwls.so" -type f  ! -name "wls.ko"  -exec rm {} \;
  sleep 1

echo "create sdk cc"
find ./sdk/   -name  *.cc -exec rm {} \;
  sleep 1

echo "create sdk cpp"
find ./sdk/   -name  *.cpp -exec rm {} \;

