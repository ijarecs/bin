#!/usr/bin/bash

while [ 1 ];
do
	if [ "$(/usr/bin/mount -t fuse)" = "" ];
	then
		echo && /usr/bin/date && /usr/bin/mount -v /home/ijarecs/mnt/gmx-ijarecs && echo  "~ijarecs/mnt/gmx-ijarecs mounted"
	fi
	sleep 10
done
