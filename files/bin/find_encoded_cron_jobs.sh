#!/bin/bash
# The following command will find users who have encoded cron jobs
for user in $(awk -F: '$3 >= 1000' /etc/passwd | cut -f1 -d:); do crontab -u "$user" -l 2>/dev/null | grep -E 'base64|gzinflate|str_rot13' >/dev/null && echo "$user"; done
