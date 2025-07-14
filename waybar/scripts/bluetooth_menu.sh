#!/bin/bash

# Power on Bluetooth
bluetoothctl power on &>/dev/null

# List devices
devices=$(bluetoothctl devices | sed 's/Device //')
[ -z "$devices" ] && notify-send "Bluetooth" "No devices found" && exit 1

# Let user choose device
chosen=$(echo "$devices" | wofi --dmenu -p "Bluetooth Device")
[ -z "$chosen" ] && exit

mac=$(echo "$chosen" | awk '{print $1}')
name=$(echo "$chosen" | cut -d' ' -f2-)

# Toggle connection
if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
  bluetoothctl disconnect "$mac"
  notify-send "Bluetooth" "Disconnected from $name"
else
  bluetoothctl connect "$mac"
  notify-send "Bluetooth" "Connected to $name"
fi
