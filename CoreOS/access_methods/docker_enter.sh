#!/bin/bash

if [ "$1" == "" ]; then
	echo Usage: $0 CONTAINER_ID_OR_NAME
	echo
	echo Used to access docker containers that have the ssh service running.
	echo SSH key will be injected into container to make this work.
	exit
fi

if [ ! -f ~/.sshto/key ]; then
	mkdir ~/.sshto
	ssh-keygen -t rsa -N "" -f ~/.sshto/key
fi

dir=$(docker inspect nimble | awk -F'"' '{if($2 == "ID") print $4}')
imgpath="/var/lib/docker/btrfs/subvolumes/$dir"

if [ -d "$imgpath" ]; then
	CONTAINERPATH="$imgpath";
	SSHKEYDIR="$CONTAINERPATH/root/.ssh"

	if [ ! -d "$SSHKEYDIR" ]; then
		mkdir "$SSHKEYDIR"
	fi

	cat ~/.sshto/key.pub >> $SSHKEYDIR/authorized_keys

	cat "$SSHKEYDIR/authorized_keys" | sort | uniq > "$SSHKEYDIR/authorized_keys_tmp"
	cat "$SSHKEYDIR/authorized_keys_tmp" > "$SSHKEYDIR/authorized_keys"
	chmod 700 "$SSHKEYDIR"
	chmod 600 "$SSHKEYDIR/authorized_keys"
	rm -rf "$SSHKEYDIR/authorized_keys_tmp"

	echo Attempting to place you into the $1 container...

	SSHCMD=$(docker inspect "$1" | grep IPAddress | awk -F'"' '{print "ssh -i ~/.sshto/key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"$4" -q"}')
	echo $SSHCMD
	eval $SSHCMD
else
	echo Image $1 not found.
fi
