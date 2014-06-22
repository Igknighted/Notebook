#!/bin/bash

echo Problems will exist when trying to inspect processes.
echo Problems will exist when trying to inspect processes.
echo Problems will exist when trying to inspect processes.

dir=$(docker inspect nimble | awk -F'"' '{if($2 == "ID") print $4}')
imgpath="/var/lib/docker/btrfs/subvolumes/$dir"

if [ -d "$imgpath" ]; then
	chroot $imgpath
fi
