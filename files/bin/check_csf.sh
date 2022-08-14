#!/bin/bash
if [ -d /etc/csf ]; then
    if [[ "$(sudo csf --status | grep DROP -c)" -gt 0 ]]; then
        if [[ "$(ps aux | grep 'lfd' | grep -v grep | wc -l)" -eq 0 ]]; then
            echo "CSF WARNING - CSF is running but LFD is stopped"
            exit 1
        fi
        #echo "CSF OK - Running"
        echo 1
        exit 0
    else

        #echo "CSF CRITICAL - NOT Running"
        echo 0
        exit 2
    fi
else
    #echo "CSF CRITICAL - NOT installed"
    echo 3
    exit 2
fi

