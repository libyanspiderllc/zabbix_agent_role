#!/bin/bash

# Usage: script.sh <cpanel_user> <userparameter>
# $1 = cPanel username
# $2 = UserParameter type (must be provided)

CPUSER="$1"
USERPARAM="$2"

# Exit if CPUSER or USERPARAM is empty
if [[ -z "$CPUSER" || -z "$USERPARAM" ]]; then
    exit 1
fi

# Function to run uapi and output only if success
run_uapi() {
    local CMD="$1"
    OUTPUT=$( /usr/local/cpanel/bin/uapi --user="$CPUSER" $CMD --output=json 2>/dev/null )
    if [[ $? -eq 0 ]]; then
        echo "$OUTPUT" | jq .result.data
    fi
}

# Decide which command to run
case "$USERPARAM" in
    cpanel_user_count_forwarders)
        run_uapi "Email count_forwarders"
        ;;
    cpanel_user_list_forwarders)
        run_uapi "Email list_forwarders"
        ;;
    cpanel_user_count_filters)
        run_uapi "Email count_filters"
        ;;
    cpanel_user_list_filters)
        run_uapi "Email list_filters"
        ;;
    cpanel_user_last_login_ip)
        run_uapi "LastLogin get_last_or_current_logged_in_ip"
        ;;
    *)
        # Unknown parameter → exit silently with code 1
        exit 1
        ;;
esac