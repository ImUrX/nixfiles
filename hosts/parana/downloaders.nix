{
  config,
  pkgs,
  lib,
  ...
}:
let
  squidUser = "306";
  squidGroup = "169";
in
rec {
  imports = [
    ./arrs.nix
    ../../modules/wg-pnp.nix
    ../../modules/soulseek.nix
  ];
  nixarr.enable = true;
  # users.users.streamer.extraGroups = [ "media" ];

  # VPN
  nixarr.vpn = {
    enable = true;
    wgConf = config.age.secrets.vpn-ar.path;
  };
  vpnNamespaces.wg.accessibleFrom = lib.mkForce [
    "192.168.0.0/16"
    "100.100.0.0/16"
    "127.0.0.1"
  ];

  # Transmission
  nixarr.transmission = {
    enable = true;
    flood.enable = true;
    messageLevel = "info";
    vpn.enable = true;

    # Doesn't build
    privateTrackers.cross-seed = {
      # enable = true;
      indexIds = [
        12
        16
        10
        11
      ];
      extraSettings = {
        delay = 60;
        excludeRecentSearch = "90 days";
        excludeOlder = "450 days";
        matchMode = "partial";
        linkDirs = [ "/data/media/torrents/manual" ];
      };
    };

    extraSettings = {
      port-forwarding-enabled = false;
      rpc-host-whitelist = "*";
    };
  };

  uri.wg-pnp.transmission = {
    vpnNamespace = "wg";
    runScript = ''
      if [ "$protocol" = tcp ]
      then
        echo "Telling transmission to listen on peer port $new_port."
        ${pkgs.transmission}/bin/transmission-remote 192.168.15.1 --port "$new_port"
      fi
    '';
  };

  # Sabnzbd
  nixarr.sabnzbd = {
    enable = true;
    whitelistHostnames = [ "nz.2dgirls.date" ];
  };

  # Rsync
  systemd.paths.bitrate-movies = {
    enable = true;
    pathConfig = {
      PathChanged = "/data/media/library/movies";
    };
  };
  systemd.services.bitrate-movies = {
    enable = true;
    wantedBy = [ "rsyncd.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    description = "Checks for high-bitrate movies and makes a list of them";
    script = ''
      set -u
      shopt -s globstar

      function join_by {
        local d=''${1-} f=''${2-}
        if shift 2; then
          printf %s "$f" "''${@/#/$d}"
        fi
      }

      sleep 2

      allow_list=/etc/movie-list
      touch $allow_list
      allowed=( )
      cd /data/media/library/movies
      for file in **/*.mkv;
      do
        bitrate=$( ${pkgs.ffmpeg}/bin/ffprobe -v quiet -select_streams v -show_entries format=bit_rate -of compact=p=0:nk=1 "$file" )
        if (( bitrate > 45000000 )); then
          allowed+=("/$( dirname "''${file}" )/***")
        fi
      done

      join_by $'\n' "''${allowed[@]}" > $allow_list
    '';
  };
  services.rsyncd = {
    enable = true;
    settings = {
      globalSection = {
        address = "0.0.0.0";
        "max connections" = 5;
        "use chroot" = false;
        "read only" = true;
      };
      sections = {
        "movies" = {
          comment = "high-bitrate movies";
          path = "/data/media/library/movies";
          "include from" = "/etc/movie-list";
          exclude = "*";
        };
      };
    };
  };

  # Soulseek
  uri.slsk = {
    enable = true;
    downloads = "/data/media/soulseek/downloads";
    incomplete = "/data/media/soulseek/incomplete";
  };

  systemd.services.podman-soularr.partOf = [ "sysinit-reactivation.target" ];

  virtualisation.oci-containers.containers = {
    soularr = {
      autoStart = true;
      image = "mrusse08/soularr:latest";
      # extraOptions = [ "--hostuser=streamer" ];
      hostname = "soularr";
      environment = {
        TZ = "ETC/UTC";
        SCRIPT_INTERVAL = "300";
      };
      volumes = [
        "${uri.slsk.downloads}:/downloads"
        "${dirOf config.age.secrets.soularr.path}:/data"
      ];
      pull = "newer";
    };

    tidlarr = {
      autoStart = true;
      image = "ghcr.io/mgthepro/tidlarr-proxy:main";
      hostname = "tidlarr";
      environment = {
        TZ = "ETC/UTC";
        DOWNLOAD_PATH = "/data/tidlarr";
        CATEGORY = "music";
        PORT = "8688";
        API_KEY = "Testtesttest";
      };
      user = "${squidUser}:${squidGroup}";
      ports = [ "127.0.0.1:9514:8688" ];
      volumes = [ "/data/tidlarr:/data/tidlarr" ];
    };
  };
  systemd.tmpfiles.rules = [
    "d /data/tidlarr 775 ${squidUser} ${squidGroup}"
  ];
  environment.shellAliases = {
    chown-squid = "chown -R ${squidUser}:${squidGroup}";
  };

  # Plex
  nixarr.plex.enable = true;
}
