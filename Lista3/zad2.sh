#!/bin/bash

# Funkcja do konwersji bajtów na KB, MB lub GB
convert_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size} B"
    elif [ $size -lt 1048576 ]; then
        echo "$((size / 1024)) KB"
    else
        echo "$((size / 1048576)) MB"
    fi
}

# Inicjalizacja poprzednich wartości dla prędkości sieci
prev_rx_bytes=$(cat /proc/net/dev | awk '/eth0|wlan0/ {print $2}')
prev_tx_bytes=$(cat /proc/net/dev | awk '/eth0|wlan0/ {print $10}')

# Inicjalizacja dla prędkości wykresu
declare -a rx_history=(0 0 0 0 0 0 0 0 0 0)
declare -a tx_history=(0 0 0 0 0 0 0 0 0 0)

# Pętla co sekundę
while true; do
    clear

    # --- Prędkość sieci ---
    rx_bytes=$(cat /proc/net/dev | awk '/eth0|wlan0/ {print $2}')
    tx_bytes=$(cat /proc/net/dev | awk '/eth0|wlan0/ {print $10}')
    
    rx_speed=$((rx_bytes - prev_rx_bytes))
    tx_speed=$((tx_bytes - prev_tx_bytes))

    rx_speed_fmt=$(convert_size $rx_speed)
    tx_speed_fmt=$(convert_size $tx_speed)
    
    # Aktualizacja historii prędkości
    rx_history=("${rx_history[@]:1}" "$rx_speed")
    tx_history=("${tx_history[@]:1}" "$tx_speed")

    # Rysowanie wykresu prędkości sieci
    echo "Network Speed (RX/TX): $rx_speed_fmt / $tx_speed_fmt"
    echo -n "RX: "
    for rx in "${rx_history[@]}"; do
        printf "▇"
    done
    echo
    echo -n "TX: "
    for tx in "${tx_history[@]}"; do
        printf "▇"
    done
    echo

    # Zapisanie bieżących wartości jako poprzednie
    prev_rx_bytes=$rx_bytes
    prev_tx_bytes=$tx_bytes

    # --- Wykorzystanie CPU i częstotliwość ---
    echo "CPU Usage per Core:"
    cpu_count=$(nproc)
    for ((i = 0; i < cpu_count; i++)); do
        cpu_stats=$(grep "cpu$i " /proc/stat)
        cpu_time=($cpu_stats)
        idle_time="${cpu_time[4]}"
        total_time=0
        for j in "${cpu_time[@]:1}"; do
            total_time=$((total_time + j))
        done
        usage=$((100 * (total_time - idle_time) / total_time))

        freq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq 2>/dev/null || echo "N/A")
        freq_mhz=$((freq / 1000))
        echo "Core $i: $usage% @ ${freq_mhz}MHz"
    done

    # --- Czas działania systemu ---
    uptime_info=$(cat /proc/uptime)
    uptime_seconds=${uptime_info%%.*}
    days=$((uptime_seconds / 86400))
    hours=$(( (uptime_seconds % 86400) / 3600))
    minutes=$(( (uptime_seconds % 3600) / 60))
    seconds=$((uptime_seconds % 60))
    echo "Uptime: ${days}d ${hours}h ${minutes}m ${seconds}s"

    # --- Stan baterii ---
    battery_info=$(cat /sys/class/power_supply/BAT0/uevent 2>/dev/null)
    battery_capacity=$(echo "$battery_info" | grep "POWER_SUPPLY_CAPACITY=" | cut -d= -f2)
    echo "Battery: ${battery_capacity}%"

    # --- Obciążenie systemu ---
    loadavg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "System Load: $loadavg"

    # --- Wykorzystanie pamięci ---
    mem_info=$(head -n 3 /proc/meminfo)
    mem_total=$(echo "$mem_info" | awk '/MemTotal:/ {print $2}')
    mem_free=$(echo "$mem_info" | awk '/MemFree:/ {print $2}')
    mem_available=$(echo "$mem_info" | awk '/MemAvailable:/ {print $2}')
    mem_used=$((mem_total - mem_available))

    echo "Memory Usage: Used $(convert_size $((mem_used * 1024))) / Total $(convert_size $((mem_total * 1024)))"

    # Odczekaj 1 sekundę przed odświeżeniem
    sleep 1
done
