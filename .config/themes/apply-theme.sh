#!/bin/bash

THEME_NAME="$1"
THEME_DIR="$HOME/.config/themes"
THEME_PATH="$THEME_DIR/theme-$THEME_NAME.conf"
VARS_CSS="$HOME/.cache/theme-vars.css"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# === Usage and Validation ===

if [[ -z "$THEME_NAME" ]]; then
  echo "Usage: $0 [theme-name]"
  echo "Available themes:"
  ls "$THEME_DIR"/theme-*.conf | sed 's|.*/theme-\(.*\)\.conf|\1|'
  exit 1
fi

if [[ ! -f "$THEME_PATH" ]]; then
  echo "Theme '$THEME_NAME' not found at $THEME_PATH"
  exit 1
fi

echo "$THEME_NAME" >"$THEME_DIR/theme-state"
source "$THEME_PATH"

# === Helpers ===

hex_to_rgba() {
  local hex="${1#"#"}"
  local alpha="${2:-0.8}"
  printf "rgba(%d, %d, %d, %s)\n" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}" "$alpha"
}

COLOR_BACKGROUND_ALPHA=$(hex_to_rgba "$COLOR_BACKGROUND" 0.8)
COLOR_MUTED_ALPHA=$(hex_to_rgba "$COLOR_MUTED" 0.5)

# === Generate GTK Color Vars ===

cat >"$VARS_CSS" <<EOF
@define-color background ${COLOR_BACKGROUND};
@define-color foreground ${COLOR_FOREGROUND};
@define-color accent ${COLOR_ACCENT};
@define-color success ${COLOR_SUCCESS};
@define-color warning ${COLOR_WARNING};
@define-color error ${COLOR_ERROR};
@define-color info ${COLOR_INFO};
@define-color highlight ${COLOR_HIGHLIGHT};
@define-color muted ${COLOR_MUTED};
@define-color border ${COLOR_BORDER};
@define-color background-alpha ${COLOR_BACKGROUND_ALPHA};
@define-color muted-alpha ${COLOR_MUTED_ALPHA};

@define-color color0 ${COLOR_BACKGROUND};
@define-color color1 ${COLOR_ERROR};
@define-color color2 ${COLOR_SUCCESS};
@define-color color3 ${COLOR_WARNING};
@define-color color4 ${COLOR_ACCENT};
@define-color color5 ${COLOR_HIGHLIGHT};
@define-color color6 ${COLOR_INFO};
@define-color color7 ${COLOR_FOREGROUND};
@define-color color8 ${COLOR_MUTED};
@define-color color9 ${COLOR_ERROR};
@define-color color10 ${COLOR_SUCCESS};
@define-color color11 ${COLOR_WARNING};
@define-color color12 ${COLOR_ACCENT};
@define-color color13 ${COLOR_HIGHLIGHT};
@define-color color14 ${COLOR_INFO};
@define-color color15 ${COLOR_FOREGROUND};
EOF

# === Apply to Apps ===

ln -sf "$VARS_CSS" ~/.config/wofi/theme.css
ln -sf "$VARS_CSS" ~/.config/waybar/theme.css
# killall waybar && waybar &
killall -SIGUSR2 waybar

~/.config/themes/generate-kitty-config.sh
pkill -SIGUSR1 kitty

~/.config/themes/generate-dunst-config.sh
killall dunst && dunst &

~/.config/themes/generate-hyprland-config.sh
hyprctl reload

# === Wallpaper ===

wallpaper="$WALLPAPER_DIR/$THEME_NAME.webp"
[[ -f "$wallpaper" ]] && awww img "$wallpaper" --transition-type grow --transition-fps 60 --transition-duration 1

# === GTK Theme Switch ===

case "$THEME_NAME" in
Tokyo-Night-Storm) GTK_THEME_NAME="Tokyo-Night-Storm-Custom" ;;
Catppuccin) GTK_THEME_NAME="Catppuccin-Custom" ;;
Nord) GTK_THEME_NAME="Nordic-Custom" ;;
*) GTK_THEME_NAME="$THEME_NAME" ;; # fallback
esac

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# === LazyVim Theme Switch ===

case "$THEME_NAME" in
Catppuccin) THEMERY_NAME="Catppuccin" ;;
Tokyo-Night-Storm) THEMERY_NAME="Tokyo Night" ;;
Nord) THEMERY_NAME="Nord" ;;
*) THEMERY_NAME="$THEME_NAME" ;; # fallback
esac

# Trigger Themery theme switch inside Neovim
nvr --servername /tmp/nvimsocket -c "ThemeryLoad \"$THEMERY_NAME\""

# === Opencode Theme Switch ===

OPENCODE_CONFIG="$HOME/.config/opencode/tui.json"

case "$THEME_NAME" in
  Catppuccin)
    OPENCODE_THEME="catppuccin-macchiato"
    ;;
  Tokyo-Night-Storm)
    OPENCODE_THEME="tokyonight"
    ;;
  Nord)
    OPENCODE_THEME="nord"
    ;;
  *)
    OPENCODE_THEME="opencode"
    ;;
esac

mkdir -p "$(dirname "$OPENCODE_CONFIG")"

cat > "$OPENCODE_CONFIG" <<EOF
{
  "\$schema": "https://opencode.ai/tui.json",
  "theme": "$OPENCODE_THEME"
}
EOF

# === Snappy Switcher Theme ===

SNAPPY_CONFIG="$HOME/.config/snappy-switcher/config.ini"

case "$THEME_NAME" in
  Catppuccin)
    SNAPPY_THEME="catppuccin-mocha.ini"
    ;;
  Tokyo-Night-Storm)
    SNAPPY_THEME="tokyo-night.ini"
    ;;
  Nord)
    SNAPPY_THEME="nord.ini"
    ;;
  *)
    SNAPPY_THEME="snappy-slate.ini"
    ;;
esac

python <<EOF
import re
from pathlib import Path

path = Path("$SNAPPY_CONFIG")
content = path.read_text()

content = re.sub(
    r'(?m)^name\s*=\s*.*$',
    'name = $SNAPPY_THEME',
    content
)

path.write_text(content)
EOF

pkill snappy-switcher
snappy-switcher --daemon &

# === Micro Theme Switch ===

MICRO_CONFIG="$HOME/.config/micro/settings.json"

case "$THEME_NAME" in
  Catppuccin)
    MICRO_THEME="catppuccin"
    ;;
  Tokyo-Night-Storm)
    MICRO_THEME="tokyo-night"
    ;;
  Nord)
    MICRO_THEME="nord"
    ;;
  *)
    echo "No Micro theme mapping for '$THEME_NAME'"
    MICRO_THEME=""
    ;;
esac

if [[ -n "$MICRO_THEME" ]]; then
  mkdir -p "$(dirname "$MICRO_CONFIG")"
  [[ -f "$MICRO_CONFIG" ]] || printf '{}\n' >"$MICRO_CONFIG"

  tmp=$(mktemp)

  if jq --arg theme "$MICRO_THEME" \
    '.colorscheme = $theme' \
    "$MICRO_CONFIG" >"$tmp"; then
    mv "$tmp" "$MICRO_CONFIG"
  else
    rm -f "$tmp"
    echo "Failed to update Micro theme" >&2
  fi
fi

# === Notify ===

notify-send "Theme applied" "Switched to '$THEME_NAME'"
