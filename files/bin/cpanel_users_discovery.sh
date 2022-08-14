#!/bin/bash
users=`find /var/cpanel/users -type f -printf '%f\n' | grep -v -e 'system'`
echo -n "{\"data\":["

comma=1
for user in $users
do
    if [ $comma -eq 0 ]; then
        echo -n ","
    fi
    comma=0
    echo -n "{\"{#USERNAME}\":\"$user\"}"
done

echo -n "]}"