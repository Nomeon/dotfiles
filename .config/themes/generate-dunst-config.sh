#!/bin/bash

cat <<EOF > ~/.config/dunst/dunstrc
[global]
font = FiraCode Nerd Font 10
frame_color = "${COLOR_BORDER}"
separator_color = "${COLOR_ACCENT}"
corner_radius = 0
padding = 16
horizontal_padding = 20
line_height = 0
transparency = 8
monitor = 0
follow = mouse
indicate_hidden = yes
idle_threshold = 120
hide_duplicate_count = true
ignore_newline = no
show_indicators = yes
markup = full
mouse_left_click = close_current
mouse_middle_click = close_all
mouse_right_click = do_action

[urgency_low]
background = "${COLOR_BACKGROUND}"
foreground = "${COLOR_FOREGROUND}"
timeout = 5

[urgency_normal]
background = "${COLOR_BACKGROUND}"
foreground = "${COLOR_FOREGROUND}"
timeout = 8

[urgency_critical]
background = "${COLOR_ERROR}"
foreground = "${COLOR_FOREGROUND}"
frame_color = "${COLOR_ERROR}"
timeout = 0
EOF