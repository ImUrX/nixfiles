{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "3.1.2.4902-develop";
        src = pkgs.fetchurl {
          url = "https://github.com/Lidarr/Lidarr/releases/download/v3.1.2.4902/Lidarr.develop.3.1.2.4902.linux-core-x64.tar.gz";
          sha256 = "d6848526d43dfc8080085045829da43f37cfd1d2a2b4c83bbea00dee24f42930";
        };
      });
      vpn.enable = true;
    };
    readarr.enable = true;
    sonarr = {
      enable = true;
    };
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
  systemd.services.flaresolverr = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };
  };

  nixarr.recyclarr = {
    enable = true;
    configFile = ./recyclarr.yml;
  };
}
