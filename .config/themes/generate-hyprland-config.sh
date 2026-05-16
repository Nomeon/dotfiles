#!/bin/bash

hex_to_hypr_rgba() {
  local hex="${1#"#"}"
  local alpha="${2:-ff}"
  echo "rgba(${hex}${alpha})"
}

ACTIVE_BORDER=$(hex_to_hypr_rgba "$COLOR_ACCENT" ff)
INACTIVE_BORDER=$(hex_to_hypr_rgba "$COLOR_MUTED" 80)

cat <<EOF > ~/.config/hypr/hyprland-theme.lua
return {
  active_border = "${ACTIVE_BORDER}",
  inactive_border = "${INACTIVE_BORDER}",
}
EOF
