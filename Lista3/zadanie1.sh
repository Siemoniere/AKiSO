#!/bin/bash

echo -e "PID\tPPID\tComm\t\t\t\tState\trss\tTgid\tSid\tTty OpenFiles"
for pid in $(ls /proc | grep "^[0-9]\+$"); do
    if [ -f /proc/$pid/status ]; then
	PID=$(awk '/^Pid:/ {print $2}' /proc/$pid/status)
	ppid=$(awk '/^PPid:/ {print $2}' /proc/$pid/status)
	comm=$(awk '/^Name:/ {print $2}' /proc/$pid/status)
	state=$(awk '/^State:/ {print $2}' /proc/$pid/status)
	rss=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status)
	tgid=$(awk '/^Tgid:/ {print $2}' /proc/$pid/status)
	sid=$(awk '{print $6}' /proc/$pid/stat)
	#tty=$(awk '{print $7}' /proc/$pid/stat)
	tty=$(ls -l /proc/$pid/fd 2>/dev/null | grep '/dev/tty' | head -n 1 | awk '{print $NF}')
	tty=${tty:-"?"}
	open_files=$(ls /proc/$pid/fd | wc -l)
	echo -e "$PID\t$ppid\t$comm\t$state\t$rss\t$tgid\t$sid\t$tty\t$open_files"
    fi
done | column -t