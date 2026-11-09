{ pkgs, ... }: {
  nixarr = {
    radarr.enable = true;
    lidarr = {
      enable = true;
      package = pkgs.lidarr.overrideAttrs (_: {
        runtimeDeps = with pkgs; [
          ffmpeg
        ];
      });
      # vpn.enable = true;
    };
    sonarr = {
      enable = true;
    };
    # autobrr = {
    #   enable = true;
    #   vpn.enable = true;
    #   settings = {
    #     host = lib.mkForce "192.168.15.1";
    #     port = 7474;
    #   };
    # };

    bazarr.enable = true;
    prowlarr.enable = true;

    seerr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "beets-lidarr" ''
      set -euo pipefail
      
      if [ "$lidarr_eventtype" = "Test" ]; then exit 0; fi
      if [ "$lidarr_eventtype" != "TrackRetag" ]; then exit 0; fi

      BEETS_CONFIG="${./beets-import-script.yml}"

      dir="$(dirname "$lidarr_trackfile_path")"
      ${beets}/bin/beet --config="$BEETS_CONFIG" import --quiet "$dir"
    '')
  ];

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
