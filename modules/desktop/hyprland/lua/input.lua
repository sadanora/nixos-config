hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("HYPRCURSOR_THEME", cursorTheme)
hl.env("HYPRCURSOR_SIZE", tostring(cursorSize))
hl.env("XCURSOR_THEME", cursorTheme)
hl.env("XCURSOR_SIZE", tostring(cursorSize))

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "ctrl:nocaps",
    },
})
