#!/bin/sh

echo starting pihole
/usr/bin/start.sh &


SERVICESD=$(ls /etc/services.d/)
for SERVICED in ${SERVICESD}; do
	echo starting $SERVICED
	/etc/services.d/$SERVICED/run &
done


exec "$@"
