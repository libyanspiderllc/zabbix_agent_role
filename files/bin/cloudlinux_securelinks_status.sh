#!/bin/bash

# Check if CloudLinux SecureLinks Link Traversal Protection is enabled
if [ -f /etc/sysctl.d/cloudlinux-linksafe.conf ]; then
  symlinks=$(grep "^fs.protected_symlinks_create" /etc/sysctl.d/cloudlinux-linksafe.conf | awk '{print $3}')
  hardlinks=$(grep "^fs.protected_hardlinks_create" /etc/sysctl.d/cloudlinux-linksafe.conf | awk '{print $3}')
  if [ "$symlinks" = "1" ] && [ "$hardlinks" = "1" ]; then
    echo 1
  else
    echo 0
  fi
else
  echo 0
fi


