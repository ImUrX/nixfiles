{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.niri;
in
with lib;
{
  options.uri.niri = {
    enable = mkEnableOption "Enables and configures Niri";
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;

    security.pam.services.swaylock = { };
    programs.waybar.enable = true; # top bar
    environment.systemPackages = with pkgs; [
      fuzzel
      swaylock
      mako
      swayidle
      xwayland-satellite
    ];

    xdg.portal.config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ]; # or "kde"
    };
  };
}
