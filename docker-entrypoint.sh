#!/bin/bash -e

UNBOUND_CONF="/etc/unbound/unbound.conf.d/pi-hole.conf"

DAEMON="/usr/sbin/unbound"
DAEMON_OPTS="-v"

ANCHOR="/usr/sbin/unbound-anchor"

CHECKCONF="/usr/sbin/unbound-checkconf"

PIHOLE="/usr/bin/start.sh"

# ----------------------------------------------------------------

# set num-threads for unbound matching the running machine
sed -i "s/num-threads: 1/num-threads: $(nproc)/" $UNBOUND_CONF


echo starting unbound
capsh --user="unbound" --keep=1 -- -c "$ANCHOR -v"

capsh --user="unbound" --keep=1 -- -c "$CHECKCONF $UNBOUND_CONF"

capsh --user="unbound" --keep=1 -- -c "$DAEMON -d $DAEMON_OPTS -c $UNBOUND_CONF" &


echo starting pihole
$PIHOLE


exec "$@"
