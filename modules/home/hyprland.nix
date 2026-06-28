{ config, osConfig, pkgs, ... }:

let
  wallpaperFile = osConfig.var.theme.wallpaper;
  wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/${wallpaperFile}";
  clipboardMenu = pkgs.writeShellScriptBin "hypr-clipboard-menu" ''
    cliphist list | rofi -dmenu -i -p clipboard | cliphist decode | wl-copy
  '';
  keybindings = pkgs.writeShellScriptBin "hypr-keybindings" ''
    cat <<'KEYS' | rofi -dmenu -i -p keybindings
    Super + Space        App launcher
    Super + Return       Terminal
    Super + B            Browser
    Super + F            Fullscreen
    Super + K            Keybindings
    Super + V            Clipboard history
    Super + Shift + V    Audio control
    Super + W/Q          Close window
    Super + M            Exit Hyprland
    Super + S            Toggle scratchpad
    Super + Alt + L      Lock screen
    Super + Shift + N    Notifications
    Super + T            Toggle floating
    Super + Arrow        Focus window
    Super + Shift + Arrow
                         Swap window
    Super + Ctrl + Arrow Resize window
    Super + 1..0         Switch workspace
    Super + Shift + 1..0 Move window to workspace
    KEYS
  '';
in
{
  # NixOS installs and exposes the Hyprland session. Home Manager only writes
  # the user's Hyprland config for now.
  wayland.windowManager.hyprland.enable = false;

  home.packages = with pkgs; [
    rofi
    kitty
    waybar
    swaynotificationcenter
    hyprpaper
    hyprlock
    hypridle
    pamixer
    pavucontrol
    clipboardMenu
    keybindings
  ];

  home.file.".config/fcitx5/config".text = ''
    [Hotkey]
    TriggerKeys=
      Caps_Lock
    EnumerateWithTriggerKeys=True
    EnumerateForwardKeys=
    EnumerateBackwardKeys=
    ActivateKeys=
    DeactivateKeys=

    [Hotkey/TriggerKeys]
    0=Caps_Lock

    [Behavior]
    ActiveByDefault=False
    ShareInputState=No
    PreeditEnabledByDefault=True
    ShowInputMethodInformation=True
    showInputMethodInformationWhenFocusIn=False
    CompactInputMethodInformation=True
    ShowFirstInputMethodInformation=True
    DefaultPageSize=5
    OverrideXkbOption=False
  '';

  home.file.".local/share/wallpapers/${wallpaperFile}".source = "${../themes/wallpapers}/${wallpaperFile}";

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${wallpaperPath}
    wallpaper = ,${wallpaperPath}
    splash = false
  '';

  home.file.".config/hypr/hyprlock.conf".text = ''
    general {
        hide_cursor = true
    }

    background {
        monitor =
        path = ${wallpaperPath}
        color = rgb(1e1e2e)
        blur_size = 3
        blur_passes = 2
        brightness = 0.75
    }

    input-field {
        monitor =
        size = 280, 56
        outline_thickness = 2
        dots_center = true
        fade_on_empty = false
        placeholder_text = Password...
        outer_color = rgb(89b4fa)
        inner_color = rgb(11111b)
        font_color = rgb(cdd6f4)
        fail_color = rgb(f38ba8)
        position = 0, -80
        halign = center
        valign = center
    }

    label {
        monitor =
        text = $TIME
        font_size = 64
        color = rgb(cdd6f4)
        position = 0, 80
        halign = center
        valign = center
    }
  '';

  home.file.".config/hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
        timeout = 600
        on-timeout = loginctl lock-session
    }

    listener {
        timeout = 900
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
    }
  '';

  home.file.".config/hypr/hyprland.conf".text = ''
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = XDG_SESSION_DESKTOP,Hyprland
    env = XDG_SESSION_TYPE,wayland

    exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
    exec-once = uwsm app -- fcitx5 -d --replace
    exec-once = uwsm app -- hyprpaper
    exec-once = uwsm app -- waybar
    exec-once = uwsm app -- hypridle
    exec-once = uwsm app -- swaync
    exec-once = wl-paste --type text --watch cliphist store
    exec-once = wl-paste --type image --watch cliphist store
    exec-once = uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent
    exec-once = uwsm finalize

    $terminal = ${osConfig.var.apps.terminal}
    $browser = ${osConfig.var.apps.browser}
    $launcher = ${osConfig.var.apps.launcher}

    input {
        kb_layout = us
    }

    monitor = ${osConfig.var.monitors.mainConfig}
    monitor = ${osConfig.var.monitors.subConfig}

    workspace = 1, monitor:${osConfig.var.monitors.main}
    workspace = 2, monitor:${osConfig.var.monitors.main}
    workspace = 3, monitor:${osConfig.var.monitors.main}
    workspace = 4, monitor:${osConfig.var.monitors.main}
    workspace = 5, monitor:${osConfig.var.monitors.main}
    workspace = 6, monitor:${osConfig.var.monitors.sub}
    workspace = 7, monitor:${osConfig.var.monitors.sub}
    workspace = 8, monitor:${osConfig.var.monitors.sub}
    workspace = 9, monitor:${osConfig.var.monitors.sub}
    workspace = 10, monitor:${osConfig.var.monitors.sub}

    bind = SUPER, Space, exec, uwsm app -- $launcher
    bind = SUPER, Return, exec, uwsm app -- $terminal
    bind = SUPER, B, exec, uwsm app -- $browser
    bind = SUPER, F, fullscreen
    bind = SUPER, K, exec, uwsm app -- hypr-keybindings
    bind = SUPER, V, exec, uwsm app -- hypr-clipboard-menu
    bind = SUPER SHIFT, V, exec, uwsm app -- pavucontrol

    bind = SUPER, W, killactive
    bind = SUPER, Q, killactive
    bind = SUPER, M, exit
    bind = SUPER, S, togglespecialworkspace, magic
    bind = SUPER SHIFT, S, movetoworkspace, special:magic
    bind = SUPER ALT, L, exec, loginctl lock-session
    bind = SUPER SHIFT, N, exec, uwsm app -- swaync-client -t -sw
    bind = SUPER, T, togglefloating

    binde = , XF86AudioLowerVolume, exec, pamixer -d 5
    binde = , XF86AudioRaiseVolume, exec, pamixer -i 5
    bind = , XF86AudioMute, exec, pamixer -t
    bind = , XF86AudioMicMute, exec, pamixer --default-source -t

    bind = SUPER, Left, movefocus, l
    bind = SUPER, Right, movefocus, r
    bind = SUPER, Up, movefocus, u
    bind = SUPER, Down, movefocus, d

    bind = SUPER SHIFT, Left, swapwindow, l
    bind = SUPER SHIFT, Right, swapwindow, r
    bind = SUPER SHIFT, Up, swapwindow, u
    bind = SUPER SHIFT, Down, swapwindow, d

    binde = SUPER CTRL, Left, resizeactive, -60 0
    binde = SUPER CTRL, Right, resizeactive, 60 0
    binde = SUPER CTRL, Up, resizeactive, 0 -60
    binde = SUPER CTRL, Down, resizeactive, 0 60

    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10

    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10

    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow
  '';
}
