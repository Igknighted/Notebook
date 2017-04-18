#!/bin/bash

for TTYPID in $(ps aux | grep [b]ash | grep root | awk '{print $2}'); do 
  gdb -batch --eval "attach $TTYPID" --eval "call write_history(\"/tmp/bash_history-$TTYPID.txt\")" --eval 'detach' --eval 'q';
done

# This will get all the PIDs for bash processes running as root
# Issue a write_history() call to write to /tmp/bash_history-$TTYPID.txt
# Then you will see them in /tmp
