#!/bin/bash
#
# This calculator takes in the SSID and an optional MAC to calculate the wep key of a FIOS AP.
# https://xkyle.com/verizon-fios-wireless-key-calculator/
#
ESSID=`echo -n $1 | tr [A-Z] [a-z]`
len=`echo $ESSID | wc -c`
len=`expr $len - 1`
rev=""
while test $len -gt 0
do
	rev1=`echo $ESSID | cut -c$len`
	rev=$rev$rev1
	len=`expr $len - 1`
done
ESSID=$rev
MAC=$2
if [ $# -eq 1 ]; then
	#CALCWEP
	PART=`echo "obase=16; $(( 36#$ESSID ))" | bc`
	#PART=`printf "%06x" 0x$PART ` #you may need this if you are in linux
	# Based on MAC vendor information here: http://hwaddress.com/?q=ActionTec%20Electronics,%20Inc
	echo "Try one of the following, if you know the BSSID (MAC address of AP), do: $0 ESSID MAC"
	echo 1801$PART
	echo 1f90$PART
	echo 7f28$PART
	echo 0fb3$PART
	echo 1505$PART
	echo 1ea7$PART
	echo 20e0$PART
	echo 247b$PART
	echo 2662$PART
	echo 26b8$PART
elif [ $# -eq 2 ]; then
PART=`echo "obase=16; $(( 36#$ESSID ))" | bc`
	PART=`printf "%06x" 0x$PART `
	FIRST=`echo $MAC | tr -d : | tr -d "-" | tr -d [:space:] | cut -c 3-6 | tr [a-z] [A-Z]`
	echo $FIRST$PART
else
echo 'Usage: $0 ESSID [MAC]'
fi
