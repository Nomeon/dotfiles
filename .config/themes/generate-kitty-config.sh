#!/bin/bash
source ~/.config/themes/nord.theme

cat <<EOF > ~/.config/kitty/kitty.conf
font_family     FiraCode Nerd Font
bold_font       auto
italic_font     auto
font_size       11.0

# Nord Colors
background              ${COLOR_BG}
foreground              ${COLOR_FG}
selection_background    ${NORD3}
selection_foreground    ${NORD6}
cursor                  ${COLOR_FG}
cursor_text_color       ${COLOR_BG}

# Normal colors
color0  ${NORD1}
color1  ${NORD11}
color2  ${NORD14}
color3  ${NORD13}
color4  ${NORD9}
color5  ${NORD15}
color6  ${NORD8}
color7  ${NORD5}

# Bright colors
color8  ${NORD3}
color9  ${NORD11}
color10 ${NORD14}
color11 ${NORD13}
color12 ${NORD9}
color13 ${NORD15}
color14 ${NORD7}
color15 ${NORD6}

# Glass effect
background_opacity    0.90
blur                  true
window_padding_width  4
EOF
