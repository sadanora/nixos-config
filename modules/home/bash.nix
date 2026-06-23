{ config, osConfig, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nixos-rs = "sudo nixos-rebuild switch --flake /home/${osConfig.var.username}/nixos#nixos";
    };
  };
}

