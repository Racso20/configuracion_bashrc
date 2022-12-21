#!/bin/bash

archivo="/mnt/c/Windows/System32/drivers/etc/hosts"

rm -rf /etc/hosts
ln -s -f $archivo /etc/hosts
ip_vieja=$(cat $archivo | grep "kali.wsl2" | awk '{print $1}' | sort -u)
ip_nueva=$(hostname -I)


sed -i "s/$ip_vieja/$ip_nueva/g" $archivo
