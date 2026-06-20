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
  };
}

