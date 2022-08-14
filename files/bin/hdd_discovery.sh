#!/bin/bash
disks=`ls -l /dev/sg* | awk '{print $NF}' | uniq`
echo -n "{\"data\":["

comma=1
for disk in $disks
do
    ex=`smartctl -A $disk | wc -l`
    if [ $ex -gt 3 ]; then
        if [ $comma -eq 0 ]; then
                echo -n ","
        fi
        comma=0
        echo -n "{\"{#DISKNAME}\":\"$disk\",\"{#SHORTDISKNAME}\":\"${disk:5}\"}"
    fi
done

echo -n "]}"