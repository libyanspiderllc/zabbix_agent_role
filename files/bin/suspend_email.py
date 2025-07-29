#!/usr/bin/python3

import sys
import subprocess
import urllib.parse
import json

def main():
    if len(sys.argv) < 3:
        print("Usage: script.py <email> <suspend_outgoing|suspend_outgoing_and_login>")
        exit(1)

    email = sys.argv[1]
    mode = sys.argv[2].lower()

    if mode not in ['suspend_outgoing', 'suspend_outgoing_and_login']:
        print("Second argument must be either 'suspend_outgoing' or 'suspend_outgoing_and_login'")
        exit(1)

    try:
        domain = email.split('@')[1]
    except Exception:
        print('Unable to parse email address')
        exit(1)

    # Find email owner
    command = (
        "grep -R %s /var/cpanel/users | grep -v system | "
        "gawk -F':' '{print $1}' | head -n 1 | "
        "xargs egrep ^USER | gawk -F'=' '{print $2}'"
    ) % domain
    email_owner, error = subprocess.Popen(
        command,
        universal_newlines=True,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    ).communicate()

    email_owner = email_owner.strip()
    if not email_owner:
        print("Failed to determine email owner.")
        exit(1)

    success = True

    # Suspend outgoing
    if mode in ['suspend_outgoing', 'suspend_outgoing_and_login']:
        suspend_outgoing = (
            "uapi --user=%s --output=json Email suspend_outgoing email=%s"
            % (email_owner, urllib.parse.quote_plus(email))
        )
        result_outgoing, error_outgoing = subprocess.Popen(
            suspend_outgoing,
            universal_newlines=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        ).communicate()

        try:
            data_outgoing = json.loads(result_outgoing)
            status_outgoing = data_outgoing['result']['status']
            if status_outgoing != 1:
                print("Failed to suspend outgoing email.")
                success = False
        except Exception:
            print("Error parsing outgoing result.")
            success = False

    # Suspend login
    if mode == 'suspend_outgoing_and_login':
        suspend_login = (
            "uapi --user=%s --output=json Email suspend_login email=%s"
            % (email_owner, urllib.parse.quote_plus(email))
        )
        result_login, error_login = subprocess.Popen(
            suspend_login,
            universal_newlines=True,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        ).communicate()

        try:
            data_login = json.loads(result_login)
            status_login = data_login['result']['status']
            if status_login != 1:
                print("Failed to suspend login.")
                success = False
        except Exception:
            print("Error parsing login result.")
            success = False

    exit(0 if success else 1)

if __name__ == '__main__':
    main()
