#!/bin/bash

# BEGIN: Detect the OS information
if [ -f /etc/os-release ]; then
	. /etc/os-release
elif grep -q 'release 6' /etc/redhat-release; then
	DISTRO="rhel"
	VERSION_ID="6"
else
	echo ERROR: File /etc/os-release does not exist.
	exit 1
fi

if [ -f /etc/redhat-release ]; then
	DISTRO="rhel"
elif [ "$NAME" == "Ubuntu" ]; then
	DISTRO="ubuntu"
	echo Detected Ubuntu based distro.
	echo Currently unsupported
	exit
elif [ "$NAME" == "Debian GNU/Linux" ]; then
	DISTRO="debian"
	echo Detected Debian based distro.
	echo Currently unsupported
	exit
else
	echo ERROR: This server is not running a supported distro.
	exit 1
fi
# END: Detect the OS information
