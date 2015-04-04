#!/bin/bash
: <<'END'

binary-deployment-linux
=======================

Lets say you want to make a linux self installer file. You don't want your end
user to have to figure out "how to" linux. All you want them to do is just login
to their server, run a single command that runs scripts you made to automate
their setup need. This script makes that self installer for you.

Example Usage:
--------------
# create.sh    installer.bin    MY_APP_DIR    MY_APP_DIR/myscript.sh

The command above will create installer.bin, which can be executed by the end user.

My directory tree - explained...
--------------------------------
  ./MY_APP_DIR
      This is my setup application directory. It has scripts to setup my app.
  ./MY_APP_DIR/myscript.sh
      This is my script that will setup the app.
  ./MY_APP_DIR/somefiles/
      This is a directory that myscript.sh uses. It has functions and other stuff.
  ./MY_APP_DIR/templatefiles
      This directory hold configuration templates for services I'm reconfiguring
      in myscript.sh


Hope this was useful...

Credit
------
Sam Peterson - sam.igknighted@gmail.com
License: public domain
Note: I pretty much just scrapped this together with information that I googled. It's common knowledge.

END

if [ $# -lt 3 ]; then
	echo Scripted bin maker
	echo v1.0
	echo
	echo
	echo 'Created by Sam Peterson <sam.igknighted@gmail.com>'
	echo
	echo For help see: $0 --help
	exit
fi


if [ "$1" == "-h" || "$1" == "--help" || "$1" == "help" || "$#" -ne "3" ]; then
	echo Usage:
	echo
	echo
	echo $0 [bin file name] [payload directory] [run script]
	echo
	echo
	echo bin file name - this is the name of the self extracting and executing binary file that gets created
	echo
	echo payload directory - this is the directory that contains all of your scripts for execution
	echo note: it must be in pwd
	echo
	echo run script - this is the script directly inside of the payload directory that will be run upon execution of the bin file
	exit
fi



# $1 - this is the script name we're creating
# $2 - directory for the payload
# $3 - script to execute upon extraction (must be in payload directory)

echo Creating self extracting archive script
sed -e '1,/^#START_SELF_EXTRACTOR/d' -e 's:__PAYLOAD_DIR__:'$2':g' -e 's:__SCRIPT__:'$3':g' $0 > $1

echo Archiving and adding payload data to self extracting archive script
tar -czf - $2 >> $1


exit


# Self extraction script starts here
#START_SELF_EXTRACTOR

if [ -d __PAYLOAD_DIR__ ]; then
	echo "__PAYLOAD_DIR__ directory exists, can't continue."
	exit
fi

echo Extracting payload from $0
sed -e '1,/^#START_PAYLOAD/d' $0 | tar -xz
bash __PAYLOAD_DIR__/__SCRIPT__
rm -rf __PAYLOAD_DIR__

exit

# The following is a delimiter for our tarball payload to be placed after
#START_PAYLOAD
