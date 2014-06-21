#!/bin/bash

if [ "$1" == "" ]; then
	echo Usage: userxchange IP.ADD.RE.SS
	exit
fi

MODIFICATION_DIFF=$(expr `date +%s` - `date -r /etc/passwd +%s`)
if [[ $MODIFICATION_DIFF -lt 300 ]]
then

	mkdir -p /tmp/userxchange

	cd /tmp/userxchange

	scp -o StrictHostKeyChecking=no root@$1:/etc/passwd .
	scp -o StrictHostKeyChecking=no root@$1:/etc/group .

	awk -F: '{if($3<500 || $5 == "nobody") print $0}' < passwd > newpasswd
	awk -F: '{if($3<500 || $1 == "nogroup") print $0}' < group > newgroup

	awk -F: '{if($3>=500) print $0}' < /etc/passwd >> newpasswd
	awk -F: '{if($3>=500) print $0}' < /etc/group >> newgroup

	scp -o StrictHostKeyChecking=no newpasswd root@172.17.0.2:/etc/passwd
	scp -o StrictHostKeyChecking=no newgroup root@172.17.0.2:/etc/group

	cd ~

	rm -rf /tmp/userxchange

	echo Exchange done.
else
	echo Exchange not needed.
fi
