{ config, lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.var.hyprland;
  wallpaperFile = cfg.theme.wallpaper;
  wallpaperPath = "${config.home.homeDirectory}/.local/share/wallpapers/${wallpaperFile}";
  hyprpaperConfig = lib.concatStringsSep "\n" ([
    "preload = ${wallpaperPath}"
  ] ++ map
    (monitor: "wallpaper = ${monitor},${wallpaperPath}")
    cfg.monitors.wallpaperOutputs ++ [
    "splash = false"
    ""
  ]);
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
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    configType = "lua";
    extraLuaFiles = {
      "00-variables".content = ''
        mainMod = "SUPER"
        terminal = "${cfg.apps.terminal}"
        browser = "${cfg.apps.browser}"
        launcher = "${cfg.apps.launcher}"
        polkitAgent = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"

        mainMonitor = "${cfg.monitors.main}"
        subMonitor = "${cfg.monitors.sub}"
        mainMode = "${cfg.monitors.mainMode}"
        subMode = "${cfg.monitors.subMode}"
        mainPosition = "${cfg.monitors.mainPosition}"
        subPosition = "${cfg.monitors.subPosition}"
        monitorScale = "${cfg.monitors.scale}"
      '';
      "10-monitors".content = ./lua/monitors.lua;
      "20-input".content = ./lua/input.lua;
      "30-autostart".content = ./lua/autostart.lua;
      "40-binds".content = ./lua/binds.lua;
    };
  };

  home.packages = with pkgs; [
    rofi
    kitty
    waybar
    swaynotificationcenter
    hyprpaper
    hyprlock
    hypridle
    wlogout
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

  home.file.".local/share/wallpapers/${wallpaperFile}".source = "${../../themes/wallpapers}/${wallpaperFile}";

  home.file.".vscode/argv.json" = {
    force = true;
    text = builtins.toJSON {
      "enable-crash-reporter" = true;
      "password-store" = "gnome-libsecret";
    } + "\n";
  };

  xdg.configFile = {
    "hypr/hyprpaper.conf".text = hyprpaperConfig;

    "hypr/hyprlock.conf".text = ''
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

    "hypr/hypridle.conf".text = ''
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
  };
}
