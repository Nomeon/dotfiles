#!/bin/bash

THEME_DIR="$HOME/.config/themes"
APPLY_SCRIPT="$THEME_DIR/apply-theme.sh"

declare -A theme_map

# Build menu with friendly names
menu=""
for f in "$THEME_DIR"/theme-*.conf; do
  [[ -e "$f" ]] || continue
  base=$(basename "$f")
  theme_id="${base#theme-}"
  theme_id="${theme_id%.conf}"
  pretty_name=$(echo "$theme_id" | sed 's/-/ /g')
  theme_map["$pretty_name"]="$theme_id"
  menu+="$pretty_name"$'\n'
done

# No themes found
[[ -z "$menu" ]] && notify-send "No themes found" && exit 1

# Ask user
selected=$(echo "$menu" | wofi --dmenu --prompt "Choose theme" --height 200 --width 300)

# Run if selection made
if [[ -n "$selected" ]]; then
  theme_id="${theme_map[$selected]}"
  "$APPLY_SCRIPT" "$theme_id"
fi
