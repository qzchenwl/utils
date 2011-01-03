#!/bin/bash
[ $# -eq 3 ] || exit 0
wlan=$1
essid=$2
passwd=$3
sudo iwconfig $wlan enc s:$passwd [1]
sudo iwconfig $wlan enc open [1]
sudo iwconfig $wlan essid "$essid"
sudo dhclient $wlan
