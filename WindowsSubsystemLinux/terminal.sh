cd ~
export DISPLAY=:0.0 
gnome-terminal


# We need to hold the first bash command open for WSL to act right.
if [[ $(ps faux | grep bash | head -n1 | awk '{print $2}') -eq $$ ]]; then
	while true; do
		sleep 600s
		if [[ $(ps --ppid `ps aux | grep gnome-terminal-server | awk '{print $2}'` | grep -v PID) == "" ]]; then
			exit 0
		fi
	done
fi
