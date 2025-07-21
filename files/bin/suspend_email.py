#!/usr/bin/python3

import sys
import subprocess
import urllib.parse
import json

def main():
	if len(sys.argv) < 2:
		print ("Argument missing: Supply an Email address")
		exit(1)

	email = sys.argv[1]

	try:
		domain = email.split('@')[1]
	except Exception:
		print ('Unable to parse email address')
		exit(1)

	command = "grep -R %s /var/cpanel/users | grep -v system | gawk -F':' '{print $1}' | head -n 1 | xargs egrep ^USER | gawk -F'=' '{print $2}'" % domain
	email_owner,error  = subprocess.Popen(command, universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
	suspend_outgoing = "uapi --user=%s --output=json Email suspend_outgoing email=%s" % (email_owner.strip('\n'), urllib.parse.quote_plus(email))
	suspend_login = "uapi --user=%s --output=json Email suspend_login email=%s" % (email_owner.strip('\n'), urllib.parse.quote_plus(email))
	result_outgoing, error_outgoing = subprocess.Popen(suspend_outgoing, universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
	result_login, error_login = subprocess.Popen(suspend_login, universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()

	try:
            data_outgoing = json.loads(result_outgoing)
            data_login = json.loads(result_login)
            status_outgoing = data_outgoing['result']['status']
            status_login = data_login['result']['status']
            if status_outgoing == 1 and status_login == 1:
                exit(0)
            else:
                exit(1)
	except Exception as e:
		exit(1)

if __name__ == '__main__':
	main()
