#!/bin/bash

convert() {
    size=$1
    if [ "$size" -lt 1024 ]; then
	echo "$size B"
    elif [ "$size" -lt 1048576 ]; then
	echo "$((size/1024)) kB"
    else
	echo "$((size/1048576)) MB"
    fi
}

previous_receive=$(awk '/wlp0s20f3/ {print $2}' /proc/net/dev)
previous_transmit=$(awk '/wlp0s20f3/ {print $10}' /proc/net/dev)

while true; do
    clear
    battery=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_CAPACITY=" | cut -d'=' -f2) 
    echo "Battery: $battery%"

    loadavg=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo "System load: $loadavg"

    mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    mem_used=$((mem_total-mem_available))
    echo "Memory used: $(convert $((mem_used*1024))) / $(convert $((mem_total*1024)))"

    uptime=$(awk '{print int($1)}' /proc/uptime)
    days=$((uptime/86400))
    hours=$(((uptime%86400)/3600))
    minutes=$(((uptime%3600)/60))
    seconds=$((uptime%60))
    echo "Time: ${days}d ${hours}h ${minutes}m ${seconds}s "

    echo "CPU usage per core:"
    core_number=$(nproc)
    for ((i=0; i<core_number; i++)); do
	act_time=$(awk -v i=$i '/cpu'"$i"'/ {sum = $2 + $3 + $4 + $7 + $8 + $9} END {print sum}' /proc/stat)
	total_time=$(awk -v i=$i '/cpu'"$i"'/ {sum = $2+$3+$4+$5+$6+$7+$8+$9+$10+$11} END {print sum}' /proc/stat)
	usage=$(echo "scale=2; 100*$act_time/$total_time" | bc -l)
	freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq)
	echo "Core $i: $((freq/1000)) MHz, $usage%"
    done

    current_receive=$(awk '/wlp0s20f3/ {print $2}' /proc/net/dev)
    echo $previous_receive
    current_transmit=$(awk '/wlp0s20f3/ {print $10}' /proc/net/dev)
    echo "Actual receive: $((current_receive-previous_receive)) Actual transmit: $((current_transmit-previous_transmit))"
    previous_receive=$current_receive
    previous_transmit=$current_transmit
    sleep 1
done