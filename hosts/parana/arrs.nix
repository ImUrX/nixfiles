{...}: {
  nixarr = {
    radarr.enable = true;
    lidarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;

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
