#!/bin/sh

# Start up process
/usr/libexec/instsvcdrv-helper start
/opt/dell/srvadmin/sbin/"$@"

# Grab PID
OMSA_PID=$(pgrep -of /opt/dell/srvadmin/sbin/"$@")

# Wait for it to die
while [ -e /proc/$OMSA_PID ]; do sleep 1; done