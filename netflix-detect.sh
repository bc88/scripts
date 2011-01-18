#!/bin/bash
NETFLIXSTATUS=0
NETFLIX=0
while [ 1 ]; 
do
BW=`dstat  -n --nocolor --integer --noheaders --noupdate  10 1 -N wlan0 | tail -n 1 | awk '{print $1}'`
BWK=${BW/k/}
if [[ $BW == *k ]] && [ $BWK -gt 50 ]; then
	if [ $NETFLIX = 4 ]; then
		echo -n "!"
	elif [ $NETFLIX -eq 3 ]; then
		echo -n "$NETFLIX"
		if [ $NETFLIXSTATUS -eq 0 ]; then
			echo Streaming is On! && NETFLIXSTATUS=1
		fi
		NETFLIX=4
	else
		echo -n "$NETFLIX"
		let NETFLIX=$NETFLIX+1
	fi
else
	#echo "Our BW is not in k: $BW"
        if [ $NETFLIX = -4 ]; then
                echo -n "."
        elif [ $NETFLIX -eq -3 ]; then
		echo -n "$NETFLIX"
		if [ $NETFLIXSTATUS -eq 1 ] ; then
			echo Streaming is Off! && NETFLIXSTATUS=0
		fi
                NETFLIX=-4
        else
		echo -n "$NETFLIX"
                let NETFLIX=$NETFLIX-1
        fi

fi
echo -e "\t $BW"
done
