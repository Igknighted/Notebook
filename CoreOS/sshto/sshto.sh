#!/bin/bash

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

	cat $SSHKEYDIR/authorized_keys | sort | uniq > $SSHKEYDIR/authorized_keys_tmp
	cat $SSHKEYDIR/authorized_keys_tmp > $SSHKEYDIR/authorized_keys
	rm -rf $SSHKEYDIR/authorized_keys_tmp

	echo Attempting to place you into the $1 container...

	docker inspect "$1" | grep IPAddress | awk -F'"' '{print "ssh -i ~/.sshto/key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"$4}' | bash

fi
