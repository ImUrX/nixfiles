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

  nixarr.recyclarr = {
    enable = true;
    configuration = {
      sonarr = {
        series = {
          base_url = "http://localhost:8989";
          api_key = "!env_var SONARR_API_KEY";
          quality_definition = {
            type = "series";
          };
          delete_old_custom_formats = true;
        };
      };
      radarr = {
        movies = {
          base_url = "http://localhost:7878";
          api_key = "!env_var RADARR_API_KEY";
          quality_definition = {
            type = "movie";
          };
          delete_old_custom_formats = true;
        };
      };
    };
  };
}
