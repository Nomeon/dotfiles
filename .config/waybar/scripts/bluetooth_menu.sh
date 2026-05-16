#!/bin/bash
set -u

# Full paths for reliability
BLUETOOTHCTL=$(which bluetoothctl)
WOFI=$(which wofi)
NOTIFY=$(which notify-send)

if [[ -z "${BLUETOOTHCTL}" || -z "${WOFI}" || -z "${NOTIFY}" ]]; then
  echo "Missing dependency. Need: bluetoothctl, wofi, notify-send" >&2
  exit 1
fi

ICON_CONNECTED="󰂱"
ICON_DISCONNECTED="󰂯"
ICON_BATTERY="󰥈"
ICON_PAIR="󱘖"
ICON_REMOVE=""

notify() {
  "$NOTIFY" "Bluetooth" "$1" >/dev/null 2>&1 || true
}

bt() {
  "$BLUETOOTHCTL" "$@" 2>/dev/null || true
}

# Extract MAC address like [AA:BB:CC:DD:EE:FF] from a menu line
extract_mac() {
  sed -n 's/.*\[\([0-9A-Fa-f:]\{17\}\)\].*/\1/p'
}

# Extract device name from a menu line like "ICON Name [MAC] ..."
extract_name() {
  sed -E 's/^[^ ]+ (.*) \[[0-9A-Fa-f:]{17}\].*$/\1/'
}

# Ensure Bluetooth is on
bt power on >/dev/null
bt agent on >/dev/null
bt default-agent >/dev/null

# Main menu
action=$(
  echo -e "󰂯 Manage Devices\n$ICON_PAIR Pair New Device\n$ICON_REMOVE Remove Device" |
    $WOFI --dmenu --prompt "Bluetooth Menu" --height 250 --width 300
)
[[ -z "$action" ]] && exit 0

# ============ OPTION 1: MANAGE DEVICES ============
if [[ "$action" == *"Manage Devices"* ]]; then
    raw_devices="$(bt devices | grep "^Device" || true)"

  devices=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac="$(echo "$line" | awk '{print $2}')"
    name="$(echo "$line" | cut -d' ' -f3-)"

    [[ "$mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

    info="$(bt info "$mac")"
    echo "$info" | grep -q "Paired: yes" || continue

    devices+="$mac $name"$'\n'
  done <<<"$raw_devices"

  if [[ -z "$devices" ]]; then
    notify "No paired devices found"
    exit 0
  fi

  menu="🔌 Connected Devices\n"
  while IFS= read -r device; do
    [[ -z "$device" ]] && continue
    mac="$(echo "$device" | awk '{print $1}')"
    name="$(echo "$device" | cut -d' ' -f2-)"
    [[ -z "$mac" || -z "$name" ]] && continue

    info="$(bt info "$mac")"
    if echo "$info" | grep -q "Connected: yes"; then
      battery="$(echo "$info" | sed -n 's/.*Battery Percentage:.*(\([0-9]\+\)).*/\1/p')"
      battery_display=""
      [[ -n "$battery" ]] && battery_display="$ICON_BATTERY${battery}%"
      menu+="$ICON_CONNECTED $name [$mac] $battery_display\n"
    fi
  done <<<"$devices"

  menu+="\n📶 Disconnected Devices\n"
while IFS= read -r device; do
    [[ -z "$device" ]] && continue
    mac="$(echo "$device" | awk '{print $1}')"
    name="$(echo "$device" | cut -d' ' -f2-)"
    [[ -z "$mac" || -z "$name" ]] && continue

    info="$(bt info "$mac")"
    if ! echo "$info" | grep -q "Connected: yes"; then
      battery="$(echo "$info" | sed -n 's/.*Battery Percentage:.*(\([0-9]\+\)).*/\1/p')"
      battery_display=""
      [[ -n "$battery" ]] && battery_display="$ICON_BATTERY${battery}%"
      menu+="$ICON_DISCONNECTED $name [$mac] $battery_display\n"
    fi
  done <<<"$devices"

  chosen="$(echo -e "$menu" | "$WOFI" --dmenu --prompt "Toggle Device" --height 400 --width 450)"
  [[ -z "$chosen" ]] && exit 0

  mac="$(echo "$chosen" | extract_mac)"
  name="$(echo "$chosen" | extract_name)"

  [[ -z "$mac" ]] && exit 0

  info="$(bt info "$mac")"
  if echo "$info" | grep -q "Connected: yes"; then
    bt disconnect "$mac" >/dev/null
    notify "Disconnected from $name"
  else
    bt connect "$mac" >/dev/null
    notify "Connected to $name"
  fi
  exit 0
fi

# ============ OPTION 2: PAIR NEW DEVICE ============
if [[ "$action" == *"Pair New Device"* ]]; then
  notify "Scanning for new devices..."
  bt scan on >/dev/null &
  scan_pid=$!
  sleep 12
  bt scan off >/dev/null
  kill "$scan_pid" >/dev/null 2>&1 || true

  all_devices="$(bt devices | grep "^Device" || true)"

  paired_macs="$(
    echo "$all_devices" | while read -r line; do
      [[ -z "$line" ]] && continue
      mac="$(echo "$line" | awk '{print $2}')"
      info="$(bt info "$mac")"
      echo "$info" | grep -q "Paired: yes" && echo "$mac"
    done
  )"

  menu=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac="$(echo "$line" | awk '{print $2}')"
    name="$(echo "$line" | cut -d' ' -f3-)"

    [[ -z "$mac" || -z "$name" ]] && continue

    if ! echo "$paired_macs" | grep -qx "$mac"; then
      menu+="$ICON_PAIR $name [$mac]\n"
    fi
  done <<<"$all_devices"

  if [[ -z "$menu" ]]; then
    notify "No new devices found (or scan window too short)"
    exit 0
  fi

  chosen="$(echo -e "$menu" | "$WOFI" --dmenu --prompt "Pair Device" --height 400 --width 450)"
  [[ -z "$chosen" ]] && exit 0

  mac="$(echo "$chosen" | extract_mac)"
  name="$(echo "$chosen" | extract_name)"
  [[ -z "$mac" ]] && exit 0

  # Ensure agent is ready (pairing often fails without this)
  bt agent on >/dev/null
  bt default-agent >/dev/null

  bt pair "$mac" >/dev/null
  bt trust "$mac" >/dev/null
  bt connect "$mac" >/dev/null

  notify "Paired and connected to $name"
  exit 0
fi

# ============ OPTION 3: REMOVE DEVICE ============
if [[ "$action" == *"Remove Device"* ]]; then
  raw_devices="$(bt devices | grep "^Device" || true)"

  menu=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac="$(echo "$line" | awk '{print $2}')"
    name="$(echo "$line" | cut -d' ' -f3-)"

    [[ -z "$mac" || -z "$name" ]] && continue

    info="$(bt info "$mac")"
    echo "$info" | grep -q "Paired: yes" || continue

    menu+="$ICON_REMOVE $name [$mac]\n"
  done <<<"$raw_devices"

  if [[ -z "$menu" ]]; then
    notify "No paired devices to remove"
    exit 0
  fi

  chosen="$(echo -e "$menu" | "$WOFI" --dmenu --prompt "Remove Device" --height 400 --width 450)"
  [[ -z "$chosen" ]] && exit 0

  mac="$(echo "$chosen" | extract_mac)"
  name="$(echo "$chosen" | extract_name)"
  [[ -z "$mac" ]] && exit 0

  bt remove "$mac" >/dev/null
  notify "Removed device: $name"
  exit 0
fi

exit 0