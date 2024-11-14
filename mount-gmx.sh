#!/usr/bin/bash

while [ "$(/usr/bin/hostname -I)" = "" ];
do
	#/usr/bin/sleep 1;
	echo && /usr/bin/date && echo "No network connection!"
	exit 0
done
echo && /usr/bin/date && /usr/bin/mount -v /home/ijarecs/mnt/gmx-ijarecs

#export DISPLAY=:0
#/usr/bin/nautilus -w "/home/ijarecs/mnt/gmx-ijarecs" &
#sleep 5
#killall -9 nautilus
