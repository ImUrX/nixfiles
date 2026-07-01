{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = inputs.nixpkgs-lidarr.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lidarr;
      vpn.enable = true;
    };
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

    seerr.enable = true;
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
