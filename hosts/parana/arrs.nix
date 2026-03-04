{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "3.1.2.4902-develop";
        src = pkgs.fetchurl {
          url = "https://dev.azure.com/Lidarr/Lidarr/_apis/build/builds/4873/artifacts?artifactName=Packages&fileId=CE73236DB593666413C718979FA61AEB2C3F46760B19AC16C1580919571CB31F02&fileName=Lidarr.develop.3.1.2.4914.linux-core-x64.tar.gz&api-version=5.1";
          sha256 = "0653a79c1df5d5fd4305c38847c01caea49997157f3fd53f18dd537e41ed4051";
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
