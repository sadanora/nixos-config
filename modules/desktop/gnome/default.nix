{ ... }:

{
  # GNOME is kept as a reliable fallback session for recovery and troubleshooting.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
