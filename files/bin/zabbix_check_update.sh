#!/usr/bin/env bash
# From https://github.com/kvz/bash3boilerplate
# Require at least bash 3.x
if [[ "${BASH_VERSINFO[0]}" -lt "3" ]]; then echo "bash version < 3"; exit 1; fi
# Exit on error. Append || true if you expect an error.
set -o errexit
set -o nounset
# Bash will remember and return the highest exit code in a chain of pipes.
set -o pipefail
PATH=/bin:/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

timestamp_file="/run/zabbix/zabbix_check_update"
update_interval="86400" # 1 day
timestamp_file_mtime="0"
os=""
os_family=""
epoch=$(date "+%s")
tmpfile=$(mktemp --tmpdir=/run/zabbix)
outfile="/run/zabbix/zabbix.count.updates"

function _detectOS {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        # ID is usually the specific distro (ubuntu, centos, rocky, almalinux)
        # ID_LIKE is the upstream it's based on (debian, rhel, fedora)
        os="$ID"
        if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]] || [[ "${ID_LIKE:-}" == *"debian"* ]]; then
            os_family="debian"
        elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "rocky" ]] || [[ "$ID" == "almalinux" ]] || [[ "${ID_LIKE:-}" == *"rhel"* ]] || [[ "${ID_LIKE:-}" == *"fedora"* ]]; then
            os_family="rhel"
        else
             # Fallback or unknown
             os_family="unknown"
        fi
    else
        # Fallback for very old systems
        if [[ -e /etc/centos-release ]]; then
            os="centos"
            os_family="rhel"
        elif [[ -e /etc/debian_version ]]; then
            os="debian"
            os_family="debian"
        fi
    fi
}

function _check_last_update {
    local update_needed_local="n"
    if [[ ! -e "$timestamp_file" ]]; then 
        update_needed_local="y"
    else
        timestamp_file_mtime=$(stat -c %Y "$timestamp_file")
    fi
    
    if [[ "$((epoch - timestamp_file_mtime))" -gt "$update_interval" ]]; then 
        update_needed_local="y"
    fi
    export check_needed="$update_needed_local"
}


function _check_OS_upgrades {
    pkg_to_update=""
    # If check is needed or we don't have a previous output file, we run.
    # Otherwise we try to read from existing file.
    local run_check="n"
    if [[ "$check_needed" == "y" ]] || [[ ! -f "$outfile" ]]; then
        run_check="y"
    fi

    if [[ "$run_check" == "y" ]]; then 
        if [[ "$os_family" == "debian" ]]; then 
             # For Debian, we refresh if needed
             # Original logic: check_needed means "time to refresh".
             apt-get update -q &>/dev/null || true
             touch "$timestamp_file"
             
             pkg_to_update=$((apt-get upgrade --simulate 2>&1 | grep -c '^Inst ') || true)
        
        elif [[ "$os_family" == "rhel" ]]; then
            local mgr="yum"
            if command -v dnf &> /dev/null; then
                mgr="dnf"
            fi

            # Refresh metadata
            $mgr -q makecache &> /dev/null || true
            touch "$timestamp_file"
            
            # Check for updates
            $mgr -q check-update --cacheonly &> $tmpfile || rc=$?
            
            # Logic to handle return codes
            if [[ "${rc:-0}" == 1 ]]; then
                 # Retry once?
                 $mgr -q makecache &> /dev/null || true
                 $mgr -q check-update --cacheonly &> $tmpfile || rc=$?
            fi

            if [[ "${rc:-0}" == 100 ]]; then
                # Count valid lines
                 pkg_to_update=$(grep -v '^$' $tmpfile | wc -l)
            elif [[ "${rc:-0}" == 0 ]]; then
                 pkg_to_update="0"
            else
                 # Error case
                 pkg_to_update="0"
            fi
            rm -f $tmpfile
        fi
        
        # Write to file immediately if we calculated it
        echo "$pkg_to_update" > "$outfile"
        
    else
        # Not running check, preserve existing value?
        # We don't need to do anything if we assume outfile is valid.
        # But for clarity/completeness, let's ensure we exit cleanly.
        # If we return, the main body continues.
        # Main body calls `echo "$pkg_to_update" > $outfile` at end?
        # Wait, the end of script is:
        # _check_OS_upgrades
        # echo "$pkg_to_update" > $outfile
        
        # So we must populate pkg_to_update from file!
        if [[ -f "$outfile" ]]; then
            pkg_to_update=$(cat "$outfile")
        else
             pkg_to_update="0"
        fi
    fi
}

_detectOS
_check_last_update
pkg_to_update=""
_check_OS_upgrades
# If we skipped check, pkg_to_update will hold the cached value.
# We overwrite file with same content (safe).
echo "$pkg_to_update" > "$outfile"
# Check if tmpfile exists and remove it if it does.
if [[ -f "$tmpfile" ]]; then
    rm -f "$tmpfile"
fi
