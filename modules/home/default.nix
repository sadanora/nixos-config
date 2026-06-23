{ config, osConfig, pkgs, ... }:

{
  home.username = osConfig.var.username;
  home.homeDirectory = "/home/${osConfig.var.username}";
  home.stateVersion = "26.05"; 

  imports = [
    ./bash.nix
    ./hyprland.nix
  ];

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

  programs.home-manager.enable = true;
}

