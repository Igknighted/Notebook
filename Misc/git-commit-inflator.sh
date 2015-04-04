#!/bin/bash

# This script will just inflate the age of your git commits. I was bored one night.

if [ -z "$1" ]; then
	echo Must have a argument... number of commits to forge please.
	exit
fi

cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

rm -rf .git
git init


for i in $(seq 1 $1); do
	echo "Changing $i" > ./nilfile;
	git add .
	git commit -m "Just backfilling git commits... bored."
done

git filter-branch --env-filter 'if [ -z "$DAYAGO" ]; then
	DAYAGO=1;
else
	RANDSEED=$(( ( RANDOM % 3 )  + 1 ))
	if [ "$RANDSEED" == "3" ]; then
		DAYAGO=$(echo $DAYAGO+1| bc);
	fi
fi
export GIT_AUTHOR_DATE=$(date -d "$DAYAGO day ago")
export GITCOMMITTER_DATE=$(date -d "$DAYAGO day ago")'

git remote add origin git@github.com:Igknighted/CommitInflater.git
git push origin master --force
