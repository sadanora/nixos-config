{ lib, pkgs, ... }:

{
  options.var.hyprland = {
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
          cursor = lib.mkOption {
            type = lib.types.submodule {
              options = {
                package = lib.mkOption {
                  type = lib.types.package;
                  default = pkgs.bibata-cursors;
                  description = "Cursor theme package";
                };
                name = lib.mkOption {
                  type = lib.types.str;
                  default = "Bibata-Modern-Ice";
                  description = "Cursor theme name";
                };
                size = lib.mkOption {
                  type = lib.types.int;
                  default = 24;
                  description = "Cursor size";
                };
              };
            };
            default = {};
          };
        };
      };
      default = {};
    };

    monitors = lib.mkOption {
      type = lib.types.submodule {
        options = {
          main = lib.mkOption {
            type = lib.types.str;
            default = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. M27Q P 23313B000511";
            description = "Identifier for the main monitor";
          };
          sub = lib.mkOption {
            type = lib.types.str;
            default = "desc:I-O Data Device Inc EX-LDH271D 128R120705RF";
            description = "Identifier for the sub monitor";
          };
          mainMode = lib.mkOption {
            type = lib.types.str;
            default = "2560x1440@143.97";
            description = "Hyprland mode for the main display";
          };
          subMode = lib.mkOption {
            type = lib.types.str;
            default = "preferred";
            description = "Hyprland mode for the secondary display";
          };
          mainPosition = lib.mkOption {
            type = lib.types.str;
            default = "0x0";
            description = "Hyprland position for the main display";
          };
          subPosition = lib.mkOption {
            type = lib.types.str;
            default = "0x-1080";
            description = "Hyprland position for the secondary display";
          };
          scale = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Hyprland scale for both displays";
          };
          wallpaperOutputs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "DP-6"
              "HDMI-A-2"
            ];
            description = "Hyprpaper output names to apply the desktop wallpaper to";
          };
        };
      };
      default = {};
    };
  };
}
