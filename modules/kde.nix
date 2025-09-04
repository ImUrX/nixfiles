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
    services.xserver.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";

    environment.systemPackages = with pkgs; [
      kdePackages.kdeconnect-kde
      kdePackages.kleopatra
      kdePackages.filelight
      kdePackages.yakuake
      kdePackages.kcalc
      kdePackages.partitionmanager
      kdePackages.konversation
      kdePackages.skanpage
      kdePackages.fcitx5-configtool
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
