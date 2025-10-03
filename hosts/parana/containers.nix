{ config, ... }:
{
  imports = [
    ../../modules/paperless.nix
    ../../modules/immich.nix
    ../../modules/matrix.nix
    ../../modules/misskey.nix
  ];

  networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno1";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "f63de86d-a4b9-43d3-b865-5a40f37ef85b" = {
        credentialsFile = "${config.age.secrets.cloudflared.path}";
        default = "http_status:404";
      };
    };
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  systemd.tmpfiles.rules = [
    "d /data/speedtest 755 1000 1000"
    "d /data/scrobbler 755 1000 1000"
  ];

  virtualisation.oci-containers.containers = {
    speedtest = {
      autoStart = true;
      image = "lscr.io/linuxserver/speedtest-tracker:latest";
      ports = [ "6814:80" ];
      volumes = [
        "/data/speedtest:/config"
      ];
      environment = {
        DB_CONNECTION = "sqlite";
        PUID = "1000";
        PGID = "1000";
      };
      environmentFiles = [
        config.age.secrets.speedtest.path
      ];
    };

    multi-scrobbler = {
      autoStart = true;
      image = "foxxmd/multi-scrobbler";
      environment = {
        TZ = "America/Argentina/Buenos_Aires";
        BASE_URL = "https://scrobbler.2dgirls.date";
        PLEX_URL = "http://10.88.0.1:32400";
      };
      environmentFiles = [ config.age.secrets.scrobbler.path ];
      volumes = [ "/data/scrobbler:/config" ];
      ports = [ "9078:9078" ];

    };
  };

  uri.paperless.enable = true;
  uri.immich.enable = true;
  uri.matrix.enable = true;
  uri.misskey.enable = true;
}
