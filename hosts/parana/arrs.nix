{ lib, pkgs, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        version = "3.1.1.4884-plugin";
        src = pkgs.fetchurl {
          url = "https://dev.azure.com/Lidarr/Lidarr/_apis/build/builds/4843/artifacts?artifactName=Packages&fileId=0C1EC62228982121842F4234164A8D54D08036CFC429B0D4F15D226170D2A8E902&fileName=Lidarr.merge.3.1.1.4884.linux-core-x64.tar.gz&api-version=5.1";
          sha256 = "sha256-E2w68x22nlfrWTeuUa+EjeIsNCBqZzlya9sOyqUBukA=";
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
