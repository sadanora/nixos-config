{ config, lib, ... }:

{
  options.var = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "sadanora";
      description = "Default username";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "Default hostname";
    };

    apps = lib.mkOption {
      type = lib.types.submodule {
        options = {
          terminal = lib.mkOption {
            type = lib.types.str;
            default = "kitty";
            description = "Default terminal command";
          };
          browser = lib.mkOption {
            type = lib.types.str;
            default = "google-chrome-stable";
            description = "Default browser command";
          };
          launcher = lib.mkOption {
            type = lib.types.str;
            default = "rofi -show drun";
            description = "Default application launcher command";
          };
        };
      };
      default = {};
    };

    theme = lib.mkOption {
      type = lib.types.submodule {
        options = {
          wallpaper = lib.mkOption {
            type = lib.types.str;
            default = "galaxy.webp";
            description = "Default wallpaper file from modules/themes/wallpapers";
          };
        };
      };
      default = {};
    };

    # Monitor configurations
    monitors = lib.mkOption {
      type = lib.types.submodule {
        options = {
          main = lib.mkOption {
            type = lib.types.str;
            default = "DP-3";
            description = "Identifier for the main monitor";
          };
          sub = lib.mkOption {
            type = lib.types.str;
            default = "HDMI-A-1";
            description = "Identifier for the sub monitor";
          };
          mainConfig = lib.mkOption {
            type = lib.types.str;
            default = "DP-3, 2560x1440@143.98, 0x0, auto";
            description = "Hyprland monitor rule for the main display";
          };
          subConfig = lib.mkOption {
            type = lib.types.str;
            default = "HDMI-A-1, preferred, 0x-1080, auto";
            description = "Hyprland monitor rule for the sub display";
          };
        };
      };
      default = {};
    };
  };

  config = {
    networking.hostName = config.var.hostname;
  };
}
