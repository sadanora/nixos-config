{ config, osConfig, pkgs, ... }:

{
  # NixOS installs and exposes the Hyprland session. Home Manager only writes
  # the user's Hyprland config for now.
  wayland.windowManager.hyprland.enable = false;

  home.file.".config/hypr/hyprland.conf".text = ''
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = XDG_SESSION_DESKTOP,Hyprland
    env = XDG_SESSION_TYPE,wayland

    exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
    exec-once = fcitx5 -d --replace

    env = GDK_SCALE,2

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

    bind = SUPER, Return, exec, gnome-terminal
    bind = SUPER, W, killactive
    bind = SUPER, M, exit

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
  '';
}
