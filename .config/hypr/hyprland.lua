----------------
--- MONITORS ---
----------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})

----------------
--- PROGRAMS ---
----------------

local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "wofi --show drun"
local browser     = "firefox"

-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("kitty --class floating-term -e sh -c 'fastfetch; read'")
end)

---------------------
--- ENV VARIABLES ---
---------------------

hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_EGL_NO_MODIFIERS", "1")

---------------
--- GENERAL ---
---------------

hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 15,
        border_size      = 1,
        layout           = "dwindle",
        resize_on_border = true
    },
    decoration = {
        rounding = 0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
        }
    },
    input = {
        kb_layout          = "us",
        numlock_by_default = true,
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
    dwindle = {
        preserve_split = true,
    }
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-------------------
--- KEYBINDINGS ---
-------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("~/.config/themes/theme-chooser.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/waybar/scripts/power-menu.sh"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd("brightnessctl set 10%-"))
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock -c ~/.config/hyprlock/hyprlock.conf"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -50, y = 0 }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 50 }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -50 }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 50, y = 0 }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------
--- WINDOWRULES ---
-------------------

hl.window_rule({
    name = "transparent-zed",
    match = {
        class = "dev.zed.Zed",
    },
    opacity = "0.9 0.8"
})

hl.window_rule({
    name = "floating-term",
    match = {
        class = "floating-term",
    },
    float = true,
    size = { 880, 400 },
    move = { 140, 250 },
})

----------------------
--- THEME SWITCHER ---
----------------------

local theme = dofile(os.getenv("HOME") .. "/.config/hypr/hyprland-theme.lua")

hl.config({
    general = {
        col = {
            active_border = theme.active_border,
            inactive_border = theme.inactive_border,
        },
    },
})
