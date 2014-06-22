#!/bin/bash


dir=$(docker inspect nimble | awk -F'"' '{if($2 == "ID") print $4}')
imgpath="/var/lib/docker/btrfs/subvolumes/$dir"

if [ -d "$imgpath" ]; then
	chroot $imgpath
fi
exit
