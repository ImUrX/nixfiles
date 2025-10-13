{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "2.14.5.4825-plugin";
        src = pkgs.fetchurl {
          url = "https://github.com/ImUrX/Lidarr/releases/download/2.14.5.4825-plugin/Lidarr.merge.2.14.5.4825.linux-core-x64.tar.gz";
          sha256 = "sha256-WyIelRoicY80o/3Jbzo34sQtVfZeAHyD/vi2aRggSRY=";
        };
      });
      vpn.enable = true;
    };
    readarr.enable = true;
    sonarr.enable = true;
    autobrr = {
      enable = true;
      vpn.enable = true;
      settings = {
        host = lib.mkForce "192.168.15.1";
        port = 7474;
      };
    };

    bazarr.enable = true;
    prowlarr.enable = true;

    jellyseerr.enable = true;
  };

  services.tautulli.enable = true;

  services.flaresolverr.enable = true;

  nixarr.recyclarr = {
    enable = true;
    configFile = ./recyclarr.yml;
  };
}
