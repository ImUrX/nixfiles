{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.kde;
in
with lib;
{
  options.uri.kde = {
    enable = mkEnableOption "Enables and configures KDE Plasma 6";
  };

  config = mkIf cfg.enable {
    programs.xwayland.enable = true;

    services.displayManager.plasma-login-manager = {
      enable = true;
    };

    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";

    environment.systemPackages = with pkgs.kdePackages; [
      kdeconnect-kde
      kleopatra
      filelight
      kcalc
      partitionmanager
      konversation
      skanpage
      fcitx5-configtool
      akregator
    ];

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      plasma-systemmonitor
    ];

    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        # gtkUsePortal = true;
      };
    };
  };
}
