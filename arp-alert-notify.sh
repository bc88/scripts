#!/bin/bash
export DISPLAY=:0.0
case "$5" in
    0)
MSG="IP Change Detected!";
CON="Old IP: $3
New IP: $2
Mac: $1
Type: $6
Interface: $4"
ICON=/usr/share/icons/gnome/scalable/actions/reload.svg
         ;;
    1)
MSG="Mac Address not on the White List";
         ;;
    2)
MSG="Mac Address on the Blacklist Detected";
         ;;
    3)
MSG="New Mac Address Detected";
CON="Mac: $1
IP: $2
Type: $6
Interface: $4";
ICON=/usr/share/icons/gnome/scalable/actions/add.svg
         ;;
    4)
MSG="Unauthorized Arp Request";
         ;;
    5)
MSG="Abusive ARP Requests Detected";
         ;;
    6)
MSG="Ethernet Mac and Arp Mac Mismatch!";
CON="Offending IP: $2
New Mac: $3
Old Mac: $1
Type $6
Interface: $4"
ICON=/usr/share/icons/gnome/scalable/status/important.svg

         ;;
    7)
MSG="Mac Flood Detected";
CON="Offending IP: $2
Offending Mac: $1
Target Mac: $3
Type $6
Interface: $4"
ICON=/usr/share/icons/gnome/scalable/status/error.svg
         ;;
    8)
MSG="New Mac without IP";
         ;;
    9)
MSG="IP Address Change Detected";
CON="IP: $2
Mac: $1
Type: $6
Interface: $4"
ICON=/usr/share/icons/gnome/scalable/actions/reload.svg

         ;;
esac
if [ "$CON" = "" ]; then
CON="$1: $MSG" "1: $1
2: $2
3: $3
4: $4
5: $5
6: $6" 
ICON=/usr/share/icons/gnome/scalable/status/error.svg
fi

notify-send "$MSG" "$CON" -i $ICON

