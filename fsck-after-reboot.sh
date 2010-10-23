#!/bin/bash
if [ $# -ne 1 ]; then
	echo "Usage: fsck-after-reboot-check HOSTLIST"
	exit 1
fi

HOSTLIST=$1

# I'm not proud of this, but it should get the job done...
COMMAND="
for D in \$(mount -l -t ext4,ext3,ext2 | cut -d' ' -f1 )
do
	COUNTCHECK=0
	DATECHECK=0
	MOUNTCOUNT=\`tune2fs -l \$D | grep \"^Mount count\" | cut -f 2 -d : | tr -d [:blank:]\`
	MAXMOUNTCOUNT=\`tune2fs -l \$D | grep \"^Maximum mount count\" | cut -f 2 -d : | tr -d [:blank:]\`
	if [ \$MAXMOUNTCOUNT -eq -1 ]; then
		COUNTCHECK=0
	else
	        if [ \$MOUNTCOUNT -ge \$MAXMOUNTCOUNT ]; then
		        COUNTCHECK=1 
	        fi
	fi
	CHECKDATE=\`tune2fs \$D  -l| grep \"Next check after\"  | cut -f 2-10 -d :\`
	if [ \"\$CHECKDATE\" == \"\" ] ; then
		DATECHECK=0
	else
		CHECKDATE2=\`date +%s -d \"\$CHECKDATE\"\`
		NOW=\`date +%s\`
		if [ \$CHECKDATE2 -lt \$NOW ]; then
			DATECHECK=1
		fi
	fi
	if [ \$DATECHECK -eq 1 ] || [ \$COUNTCHECK -eq 1 ]; then
		echo -n \"\$D will need an fsck       \"
	fi
done
"

set -u


# Parse through and run the COMMAND on each host, skipping commented lines
for HOST in `cat $HOSTLIST | grep -v "^#"  | cut -f 1 -d "#"`
do
	echo -n "$HOST: "
	ssh $HOST "$COMMAND"
	echo
done
