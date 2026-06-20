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
          /etc/nixos/configuration.nix
	  # variables module
	  ./variables.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users.sadanora = { config, pkgs, ... }: {
              home.username = config.var.username;
              home.homeDirectory = "/home/${config.var.username}";
              home.stateVersion = "26.05"; 

              programs.home-manager.enable = true;
            };
          }
        ];
      };
    };
  };
}

