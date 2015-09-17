#!/bin/bash

service="lsyncd"
email="username@hostname.com"
host=`hostname -f`

if systemctl status $service > /dev/null; then
	# do nothing, service seems to be running
	echo > /dev/null
else
	systemctl restart $service
	subject="Restart attempt made for $service at $host"
	echo "$service at $host wasn't running and a restart was attempted" | mail -s "$subject" $email
fi
