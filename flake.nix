{
  description = "NixOS and Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./variables.nix

          home-manager.nixosModules.home-manager
          ({ config, pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users."${config.var.username}" = { osConfig, pkgs, ... }: {
              home.username = osConfig.var.username;
              home.homeDirectory = "/home/${osConfig.var.username}";
              home.stateVersion = "26.05"; 

              xdg.userDirs = {
                enable = true;
                createDirectories = true;

		extraConfig = {
		  enabled = "false";
		};

                download = "/home/${osConfig.var.username}/Downloads";
                desktop = "/home/${osConfig.var.username}/Desktop";
                documents = "/home/${osConfig.var.username}/Documents";
                music = "/home/${osConfig.var.username}/Music";
                pictures = "/home/${osConfig.var.username}/Pictures";
                videos = "/home/${osConfig.var.username}/Videos";
                templates = "/home/${osConfig.var.username}/Templates";
                publicShare = "/home/${osConfig.var.username}/Public";
              };

              wayland.windowManager.hyprland.enable = false;

              home.file.".config/hypr/hyprland.conf".text = ''
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
                bind = SUPER, W, killactive,
                bind = SUPER, M, exit,

                bind = SUPER, 1, workspace, 1
                bind = SUPER, 2, workspace, 2
                bind = SUPER, 3, workspace, 3
                bind = SUPER, 4, workspace, 4
                bind = SUPER, 5, workspace, 5
                bind = SUPER, 6, workspace, 6
                bind = SUPER, 7, workspace, 7
                bind = SUPER, 8, workspace, 8
                bind = SUPER, 9, workspace, 9
                bind = SUPER, 10, workspace, 10

                bind = SUPER_SHIFT, 1, movetoworkspace, 1
                bind = SUPER_SHIFT, 2, movetoworkspace, 2
                bind = SUPER_SHIFT, 3, movetoworkspace, 3
                bind = SUPER_SHIFT, 4, movetoworkspace, 4
                bind = SUPER_SHIFT, 5, movetoworkspace, 5
                bind = SUPER_SHIFT, 6, movetoworkspace, 6
                bind = SUPER_SHIFT, 7, movetoworkspace, 7
                bind = SUPER_SHIFT, 8, movetoworkspace, 8
                bind = SUPER_SHIFT, 9, movetoworkspace, 9
                bind = SUPER_SHIFT, 10, movetoworkspace, 10
              '';

              programs.home-manager.enable = true;
            };
          })
        ];
      };
    };
  };
}
