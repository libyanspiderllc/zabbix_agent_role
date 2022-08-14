Zabbix Agent
=========

Ansible role to install and configure Zabbix Agent (v1) on Linux and Windows hosts

Requirements
------------

- community.mysql.mysql_user

Role Variables
--------------

- zabbix_server: '' # (required) Set to hostname of Zabbix Server. Example: zabbix.mydomain.com
- zabbix_server_ip: '' # (required) Set to Public IP Address of Zabbix Server
- zabbix_version: 5.0 # (required) Set Zabbix Agent Major Version you would like to install. Example: 5.0
- zabbix_minor_version: 26 # (required) Set Zabbix Agent Minor Version you would like to install. Example: 26
- snmpd_community: '' # (optional) Set if you would like to configure Net-SNMP to allow the community from Zabbix server IP
- install_mysql_plugin: true # (optional) This will execute additional steps to configure MySQL monitoring on the host
- add_host_to_zabbix_server: false # (optional) Set to `true` if you would like the playbook to add the host to Zabbix Server via API. See below variables.
- zabbix_server_url: '' # (optional) Set to Zabbix API URL. Example: https://zabbix.mydomain.com
- zabbix_server_login_user: '' # (optional) Set to Zabbix API User
- zabbix_server_login_password: '' # (optional) Set to Zabbix API Password

Dependencies
------------

- shumbashi.firewall_ansible_role


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: shumbashi.zabbix-agent-role, zabbix_server: zabbix.mydomain.com,  zabbix_server_ip: 127.0.0.1}

License
-------

MIT

Author Information
------------------

Ahmed Shibani (#shumbashi)