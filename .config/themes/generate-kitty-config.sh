#!/bin/bash

cat <<EOF > ~/.config/kitty/kitty.conf
font_family     FiraCode Nerd Font
bold_font       auto
italic_font     auto
font_size       11.0

# Themed Colors
background              ${COLOR_BACKGROUND}
foreground              ${COLOR_FOREGROUND}
selection_background    ${COLOR_HIGHLIGHT}
selection_foreground    ${COLOR_BACKGROUND}
cursor                  ${COLOR_FOREGROUND}
cursor_text_color       ${COLOR_BACKGROUND}

# Normal colors
# black
color0  ${COLOR_BACKGROUND}
# red
color1  ${COLOR_ERROR}
# green
color2  ${COLOR_SUCCESS}
# yellow
color3  ${COLOR_WARNING}
# blue
color4  ${COLOR_ACCENT}
# magenta
color5  ${COLOR_HIGHLIGHT}
# cyan
color6  ${COLOR_INFO}
# white
color7  ${COLOR_FOREGROUND}

# Bright colors
color8  ${COLOR_MUTED}
color9  ${COLOR_ERROR}
color10 ${COLOR_SUCCESS}
color11 ${COLOR_WARNING}
color12 ${COLOR_ACCENT}
color13 ${COLOR_HIGHLIGHT}
color14 ${COLOR_INFO}
color15 ${COLOR_FOREGROUND}

# UI
background_opacity    0.8
blur                  true
window_padding_width  4
EOF
