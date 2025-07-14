#!/bin/bash

CHOICE=$(echo -e "⏻ Shutdown\n Reboot\n⏾ Suspend\n Logout" | \
  wofi --dmenu --prompt "Select action" --height 200 --width 300)

case "$CHOICE" in
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
  *Suspend) systemctl suspend ;;
  *Logout) hyprctl dispatch exit ;;
esac
