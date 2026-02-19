{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "3.1.1.4901-plugin";
        src = pkgs.fetchurl {
          url = "https://dev.azure.com/Lidarr/Lidarr/_apis/build/builds/4872/artifacts?artifactName=Packages&fileId=058198D54F6BB70DEE85C89C325D1114E1C932719BBEEFD39BB65605B92EC75902&fileName=Lidarr.merge.3.1.2.4913.linux-core-x64.tar.gz&api-version=5.1";
          sha256 = "sha256-Hi1gsQTvintVBrAdyiaXgvL25OsgQrAwgklWB6PWZv0=";
        };
      });
      vpn.enable = true;
    };
    readarr.enable = true;
    sonarr = {
      enable = true;
      package = pkgs.sonarr.overrideAttrs (_: {
        dotnetRuntimeDeps = map lib.getLib [
          (pkgs.sqlite.overrideAttrs (_: {
            version = "3.51.2";
            src = pkgs.fetchurl {
              url = "https://sqlite.org/2026/sqlite-autoconf-3510200.tar.gz";
              hash = "sha256-+9ifhmsUA7tmoUMGVEAInddhAPIjgxTZInSggtTyt7s=";
            };
          }))
        ];
      });
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
