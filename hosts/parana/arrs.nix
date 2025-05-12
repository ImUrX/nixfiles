{ lib, ... }:
{
  nixarr = {
    radarr.enable = true;
    lidarr.enable = true;
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
