{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "3.1.2.4939-develop";
        src = pkgs.fetchurl {
          url = "https://dev.azure.com/Lidarr/Lidarr/_apis/build/builds/4899/artifacts?artifactName=Packages&fileId=37FEFEA5BCBFBED50F0A13C5FD2A38A71C6E507C3DCBB8B59E894D2B8DD2E34602&fileName=Lidarr.develop.3.1.2.4939.linux-core-x64.tar.gz&api-version=5.1";
          sha256 = "bf45a7eb885241d7c9077899ba62d71edc4b0ebcddc95b136615493cacf827e7";
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
