{ config, lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.var.hyprland;
  cursor = cfg.theme.cursor;
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
  clipboardShortcut = pkgs.writeShellScriptBin "hypr-clipboard-shortcut" ''
    action="$1"
    target="$2"
    window_class="$3"

    if [ -z "$target" ]; then
      target="activewindow"
    fi
    if [ -z "$window_class" ]; then
      window_class="$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.class // ""')"
    fi

    case "$action" in
      copy)
        key="C"
        if [ "$window_class" = "kitty" ] || [ "$window_class" = "com.mitchellh.ghostty" ]; then
          modifiers="CTRL SHIFT"
        else
          modifiers="CTRL"
        fi
        ;;
      paste)
        key="V"
        if [ "$window_class" = "kitty" ] || [ "$window_class" = "com.mitchellh.ghostty" ]; then
          modifiers="CTRL SHIFT"
        else
          modifiers="CTRL"
        fi
        ;;
      cut)
        key="X"
        modifiers="CTRL"
        ;;
      *)
        echo "usage: hypr-clipboard-shortcut {copy|paste|cut}" >&2
        exit 2
        ;;
    esac

    ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "$modifiers, $key, $target"
  '';
  clipboardMenu = pkgs.writeShellScriptBin "hypr-clipboard-menu" ''
    active_window="$(${pkgs.hyprland}/bin/hyprctl activewindow -j)"
    window_address="$(printf '%s' "$active_window" | ${pkgs.jq}/bin/jq -r '.address // ""')"
    window_class="$(printf '%s' "$active_window" | ${pkgs.jq}/bin/jq -r '.class // ""')"
    if [ -n "$window_address" ]; then
      target="address:$window_address"
    else
      target="activewindow"
    fi
    selection="$(cliphist list | rofi -dmenu -i -p clipboard)"
    if [ -n "$selection" ]; then
      printf '%s' "$selection" | cliphist decode | wl-copy
      sleep 0.05
      ${clipboardShortcut}/bin/hypr-clipboard-shortcut paste "$target" "$window_class"
    fi
  '';
  keybindings = pkgs.writeShellScriptBin "hypr-keybindings" ''
    cat <<'KEYS' | rofi -dmenu -i -p keybindings
    Super + Space        App launcher
    Super + Return       Terminal
    Super + B            Browser
    Super + F            Fullscreen
    Super + K            Keybindings
    Super + C            Copy
    Super + V            Paste
    Super + X            Cut
    Super + Shift + V    Clipboard history
    Super + Alt + V      Audio control
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

        cursorTheme = "${cursor.name}"
        cursorSize = ${toString cursor.size}
      '';
      "10-monitors".content = ./lua/monitors.lua;
      "20-input".content = ./lua/input.lua;
      "30-autostart".content = ./lua/autostart.lua;
      "40-binds".content = ./lua/binds.lua;
    };
  };

  home.pointerCursor = {
    inherit (cursor) package name size;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mode = "dock";
        height = 36;
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        ipc = true;
        fixed-center = true;
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        margin-bottom = 0;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [
          "idle_inhibitor"
          "clock"
          "custom/notification"
        ];
        modules-right = [
          "cpu"
          "memory"
          "backlight"
          "pulseaudio"
          "network"
          "bluetooth"
          "tray"
          "battery"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          all-outputs = true;
          active-only = false;
          on-click = "activate";
          persistent-workspaces = {
            "*" = [
              1
              2
              3
              4
              5
              6
              7
              8
              9
              10
            ];
          };
        };

        "hyprland/window" = {
          format = "{}";
          separate-outputs = true;
          rewrite = {
            "" = "Desktop";
            "com.mitchellh.ghostty" = "Terminal";
            "zsh" = "Terminal";
            "~" = "Terminal";
          };
          max-length = 60;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰥔";
            deactivated = "";
          };
        };

        clock = {
          format = "{:%a %d %b %R}";
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#f9e2af'><b>{}</b></span>";
              weekdays = "<span color='#89b4fa'><b>{}</b></span>";
              today = "<span color='#f38ba8'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='#f38ba8'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='#f38ba8'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='#f38ba8'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='#f38ba8'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        cpu = {
          interval = 10;
          format = "󰍛 {usage}%";
          format-alt = "{icon0}{icon1}{icon2}{icon3}";
          on-click = "${cfg.apps.terminal} -e ${pkgs.btop}/bin/btop";
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
        };

        memory = {
          interval = 30;
          format = "󰾆 {percentage}%";
          format-alt = "󰾅 {used}GB";
          on-click = "${cfg.apps.terminal} -e ${pkgs.btop}/bin/btop";
          tooltip-format = " {used:.1f}GB/{total:.1f}GB";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 2%+";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
          tooltip-format = "{icon} {desc} // {volume}%";
          scroll-step = 4;
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󱘖 Wired";
          format-linked = "󰤪 Linked";
          format-disconnected = "󰤮 Off";
          format-alt = "󰤨 {signalStrength}%";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          tooltip-format = "󱘖 {ipaddr}   {bandwidthUpBytes}   {bandwidthDownBytes}";
        };

        bluetooth = {
          format = "";
          format-disabled = "󰂲";
          format-connected = " {num_connections}";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
          tooltip-format = " {device_alias}";
          tooltip-format-connected = "{device_enumerate}";
          tooltip-format-enumerate-connected = " {device_alias}";
        };

        tray = {
          icon-size = 14;
          spacing = 6;
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        "custom/power" = {
          format = "";
          on-click = "${pkgs.wlogout}/bin/wlogout -b 4";
          tooltip = false;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "CaskaydiaMono Nerd Font", "Noto Sans CJK JP", sans-serif;
        font-size: 14px;
        margin: 0;
        padding: 0;
        border: none;
        min-height: 0;
      }

      @define-color base   #1e1e2e;
      @define-color mantle #181825;
      @define-color crust  #11111b;

      @define-color text     #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color overlay0 #6c7086;

      @define-color blue      #89b4fa;
      @define-color lavender  #b4befe;
      @define-color sapphire  #74c7ec;
      @define-color teal      #94e2d5;
      @define-color green     #a6e3a1;
      @define-color yellow    #f9e2af;
      @define-color peach     #fab387;
      @define-color maroon    #eba0ac;
      @define-color red       #f38ba8;
      @define-color mauve     #cba6f7;
      @define-color pink      #f5c2e7;

      window#waybar {
        background: transparent;
        color: @text;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      tooltip {
        background: @base;
        border: 1px solid @surface1;
        border-radius: 9px;
      }

      tooltip label {
        color: @text;
        margin: 6px;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: alpha(@base, 0.88);
        border: 1px solid @surface1;
        border-radius: 11px;
        padding: 0 10px;
      }

      .modules-left,
      .modules-right {
        border-color: @blue;
      }

      #backlight,
      #battery,
      #bluetooth,
      #clock,
      #cpu,
      #custom-notification,
      #custom-power,
      #idle_inhibitor,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #window,
      #workspaces {
        padding: 3px 6px;
      }

      #workspaces button {
        color: @surface1;
        box-shadow: none;
        text-shadow: none;
        border-radius: 9px;
        padding: 0 5px;
        transition: all 0.25s cubic-bezier(.55,-0.68,.48,1.682);
      }

      #workspaces button:hover {
        color: @overlay0;
        background: @surface0;
      }

      #workspaces button.active {
        color: @peach;
        padding: 0 9px;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #window {
        color: @mauve;
      }

      #idle_inhibitor,
      #backlight,
      #network,
      #bluetooth {
        color: @blue;
      }

      #clock,
      #cpu {
        color: @yellow;
      }

      #memory {
        color: @green;
      }

      #pulseaudio {
        color: @lavender;
      }

      #pulseaudio.bluetooth {
        color: @pink;
      }

      #pulseaudio.muted,
      #network.disconnected,
      #network.disabled {
        color: @red;
      }

      #battery {
        color: @green;
      }

      #battery.warning {
        color: @peach;
      }

      #battery.critical:not(.charging) {
        background: @red;
        color: @crust;
        border-radius: 8px;
      }

      #custom-notification {
        color: @text;
      }

      #custom-power {
        color: @red;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }
    '';
  };

  home.packages = with pkgs; [
    rofi
    swaynotificationcenter
    hyprpaper
    hyprlock
    hypridle
    wlogout
    pamixer
    pavucontrol
    btop
    networkmanagerapplet
    blueman
    clipboardShortcut
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
