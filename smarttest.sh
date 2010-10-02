#!/bin/bash
# Simplified smart test script
# Take the guess work out of interpreting smartctl!
# Kyle Anderson
# Under the GPL
# 2009
echo "Will take 2 Minutes, please wait...."

#First let's determine the device
if [ $# -gt 0 ]; then 
	if [ -b $1 ]; then
		DRIVE=$1
	else
		echo "$1 is not a block device? Try running fdisk -l for a list of drives"
		exit
	fi
else
	#Try hda?	
	if [ -b /dev/hda ]; then
		DRIVE=/dev/hda
	elif [ -b /dev/sda ]; then
		DRIVE=/dev/sda
	else
		echo Could not autofind a drive to work with
		exit
	fi
fi

#echo "Turning on smart"
smartctl -s on $DRIVE >/dev/null 2>&1

smartctl -a $DRIVE | grep SCSI >/dev/null
if [ $? -eq 0 ]; then #This means the drive is scsi
smartctl --test short $DRIVE >/dev/null 2>&1
sleep 2m
HOURS=`smartctl -a $DRIVE | grep "# 1" | cut -f 2 -d "-" | tr -d [:space:]`
if [ "$HOURS" = "NOW" ]; then
	echo "This smart test is taking more than two minutes... waiting another minute..."
	sleep 1m
	HOURS=`smartctl -a $DRIVE | grep "# 1" | cut -f 2 -d "-" | tr -d [:space:]`
	if [ "$HOURS" = "NOW" ]; then
		echo "This smart test is taking more than three minutes... waiting another minute..."
		sleep 1m
		HOURS=`smartctl -a $DRIVE | grep "# 1" | cut -f 2 -d "-" | tr -d [:space:]`
		if [ "$HOURS" = "NOW" ]; then
			echo "This smart test is taking more than 4 minutes... waiting another minute..."
			sleep 1m
			HOURS=`smartctl -a $DRIVE | grep "# 1" | cut -f 2 -d "-" | tr -d [:space:]`
			if [ "$HOURS" = "NOW" ]; then
				echo "This smart test is taking more than 5 minutes... quiting..."
				exit 1
			fi
		fi
	fi
fi
	
ERRORCOUNT=`smartctl -a $DRIVE | grep "Non-medium" | cut -f 2 -d : | tr -d [:space:]`

if [ "$ERRORCOUNT" = "" ] ; then
ERRORCOUNT=0
fi
SPEED=`hdparm -t $DRIVE | tr " " "\n" | tail -n 2 | head -n 1 | cut -f 1 -d .`
READERRORS=`smartctl -a $DRIVE  | grep "read:" | cut -c 82-90 | tr -d [:space:]`
WRITEERRORS=`smartctl -a $DRIVE  | grep "write:" | cut -c 82-90 | tr -d [:space:]`
MODELNUMBER=`smartctl -a $DRIVE | grep "Device Model" | head -n 1 | awk '{print $3,$4}'`
SIZE=`smartctl -a $DRIVE | grep "User" | head -n 1 | awk '{print $3}'`


SIZE=`fdisk -l $DRIVE | grep GB | cut -f 2 -d : | cut -f 1 -d , `
#echo "`date +%D` $DRIVE:"
echo -e "\033[1;42;37mTest Complete\033[0m"
echo "Size:$SIZE"
echo "Hours: $HOURS "
echo "Read / Write errors: $READERRORS / $WRITEERRORS"
echo "Non-medium Errors: $ERRORCOUNT"
echo "Read Speed: $SPEED MB/s"

echo ""

if [ $HOURS -ge 26280 ]; then
	echo -e '\033[5;1;37;41mWARNING:\033[0m  This drive has over 26,280 (3 years) hours on it and should not be used as a Primary'
fi

#if [ $ERRORCOUNT -gt 0 ]; then
#echo "WARNING: This drive has $ERRORCOUNT non-medium errors (smart errors)"
#fi

if [ $SPEED -le 25 ]; then
echo -e '\033[5;1;37;41mWARNING:\033[0m  This drive is only reading at $SPEED MB/s, which seems slow, is this drive ok and is it on a good motherboard / ide cable?'
fi
else #ATA
smartctl --test short $DRIVE >/dev/null 2>&1
sleep 2m
HOURS=`smartctl -d ata -a $DRIVE | grep "Power_On_Hours" | tr " " "\n" | tail -n 1`

if [ "$HOURS" == "" ]; then
	HOURS=`smartctl -d ata -a $DRIVE | grep "# 1" | cut -c 64-75 | tr -d [:space:]`
fi
	
MODELNUMBER=`smartctl -a $DRIVE | grep "Device Model" | head -n 1 | awk '{print $3,$4}'`
SIZE=`smartctl -a $DRIVE | grep "User" | head -n 1 | awk '{print $3}'`
ERRORCOUNT=`smartctl -d ata -a $DRIVE | grep "Error" | grep "occurred" | head -n 1 | cut -f 2 -d " "`
ERRORTIME=`smartctl -d ata -a $DRIVE | grep "Error" | grep "occurred" | head -n 1 | cut -f 8 -d " "`

if [ "$ERRORCOUNT" = "" ] ; then
ERRORCOUNT=0
ERRORTIME=0
fi
REALLOCATEDSECTORS=`smartctl -d ata -a $DRIVE | grep "Reallocated_Sector" | tr " " "\n" | tail -n 1`
SPEED=`hdparm -t $DRIVE | tr " " "\n" | tail -n 2 | head -n 1 | cut -f 1 -d .`

PENDINGSECTORS=`smartctl -d ata -a $DRIVE | grep "Current_Pending_Sector" |  tr " " "\n" | tail -n 1`

#echo "`date +%D` $DRIVE:"
echo -e "\033[1;42;37mTest Complete\033[0m"
echo "`date +%D` $DRIVE:"
echo "Hours: $HOURS "
echo -n "SMART Errors: $ERRORCOUNT"
if [ $ERRORCOUNT -gt 0 ]; then
let WHENITHAPPEND=$HOURS-$ERRORTIME
echo " (last $WHENITHAPPEND hours ago)"
else
echo
fi
echo "Reallocated / Pending: $REALLOCATEDSECTORS / $PENDINGSECTORS"
echo "Read Speed: $SPEED MB/s"

echo ""

fi


if [ $HOURS -ge 26280 ]; then
	if [ $ERRORCOUNT -eq 0 ]; then
		if [ $REALLOCATEDSECTORS -eq 0 ]; then
			if [ $PENDINGSECTORS -eq 0 ]; then
				if [ $HOURS -ge 30000 ]; then
					echo -e '\033[5;1;37;41mWARNING:\033[0mThis drive is over 30,000 hours should not be used as a primary'
				else
					echo -e '\033[5;1;37;41mWARNING:\033[0mThis drive has over 26,280 (3 years) hours on it and should not be used as a Primary'
				fi
			else
			echo -e '\033[5;1;37;41mWARNING:\033[0m This drive has over 26,280 (3 years) hours on it and should not be used as a Primary'
			fi
		else
		echo -e '\033[5;1;37;41mWARNING:\033[0m WARNING: This drive has over 26,280 (3 years) hours on it and should not be used as a Primary'
		fi
	else
	echo -e '\033[5;1;37;41mWARNING:\033[0m This drive has over 26,280 (3 years) hours on it and should not be used as a Primary'
	fi
fi

if [ $ERRORCOUNT -gt 0 ]; then
echo -e "\033[5;1;37;41mWARNING:\033[0m The last smart error was $WHENITHAPPEND hours ago, use your judgement to tell if this is relevant (use smartctl -a $DRIVE for more info)"
fi

if [ $REALLOCATEDSECTORS -gt 0 ]; then
echo -e '\033[5;1;37;41mWARNING:\033[0m This drive has some reallocated sectors, this should not be used as a primary and requires judgement if it is to be used for a secondary'
fi

if [ $PENDINGSECTORS -gt 0 ]; then
echo -e '\033[5;1;37;41mWARNING:\033[0m This drive has some pending sectors, this shouldn not be used as a primary and requires judgement if it is to be used for a secondary'
fi

if [ $SPEED -le 25 ]; then
echo -e "\033[5;1;37;41mWARNING:\033[0m This drive is only reading at $SPEED MB/s, which seems slow, is this drive ok and is it on a good motherboard and ide cable?"
fi

