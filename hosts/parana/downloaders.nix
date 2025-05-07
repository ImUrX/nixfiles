{
  config,
  pkgs,
  lib,
  ...
}: rec {
  imports = [./arrs.nix];
  nixarr.enable = true;
  users.users.streamer.extraGroups = ["media"];

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

  systemd.timers."transmission-port-forwarding" = {
    wantedBy = ["timers.target"];
    after = ["transmission.service"];
    timerConfig = {
      OnBootSec = "45s";
      OnUnitActiveSec = "45s";
      Unit = "transmission-port-forwarding.service";
    };
  };

  systemd.services."transmission-port-forwarding" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    script = ''
      set -u

      renew_port() {
        protocol="$1"
        port_file="/tmp/transmission-$protocol-port"
        touch $port_file

        result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g 10.2.0.1)"
        echo "$result"

        new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"
        old_port="$(cat "$port_file")"
        echo "Mapped new $protocol port $new_port, old one was $old_port."
        echo "$new_port" >"$port_file"

        if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i wg0
        then
          echo "New $protocol port $new_port already open, not opening again."
        else
          echo "Opening new $protocol port $new_port."
          ${pkgs.iptables}/bin/iptables -A INPUT -p "$protocol" --dport "$new_port" -j ACCEPT -i wg0
        fi

        if [ "$protocol" = tcp ]
        then
          echo "Telling transmission to listen on peer port $new_port."
          ${pkgs.transmission}/bin/transmission-remote 192.168.15.1 --port "$new_port"
        fi

        if [ "$new_port" -eq "$old_port" ]
        then
          echo "New $protocol port $new_port is the same as old port $old_port, not closing old port."
        else
          if ${pkgs.iptables}/bin/iptables -C INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i wg0
          then
            echo "Closing old $protocol port $old_port."
            ${pkgs.iptables}/bin/iptables -D INPUT -p "$protocol" --dport "$old_port" -j ACCEPT -i wg0
          else
            echo "Old $protocol port $old_port not open, not attempting to close."
          fi
        fi
      }

      renew_port udp
      renew_port tcp
    '';
  };

  # Transmission
  nixarr.transmission = {
    enable = true;
    flood.enable = true;
    messageLevel = "info";
    vpn.enable = true;

    extraSettings = {
      port-forwarding-enabled = false;
      rpc-host-whitelist = "*";
    };
  };

  # Sabnzbd
  nixarr.sabnzbd = {
    enable = true;
    whitelistHostnames = ["nz.2dgirls.date"];
  };

  systemd.tmpfiles.rules = [
    "d ${services.slskd.settings.directories.downloads} 775 streamer media"
    "d ${services.slskd.settings.directories.incomplete} 775 streamer media"
  ];

  # Soulseek
  services.slskd = {
    enable = true;
    environmentFile = config.age.secrets.soulseek.path;
    group = "media";
    domain = null;

    settings = {
      permissions.file.mode = 775;
      web = {
        authentication = {
          api_keys = {
            soularr = {key = "JYRReBr^@shK69J^KYxXG&NTYEXEqSPe1F*DZ4ct@YFcQBzVg5K96E!1&UerFza&";};
          };
        };
      };
      remote_file_management = true;
      directories = {
        downloads = "/data/media/soulseek/downloads";
        incomplete = "/data/media/soulseek/incomplete";
      };
      shares = {
        directories = ["/data/media/library/music"];
        filters = [];
      };
      rooms = [];
      soulseek.description = "42";
    };
  };
  systemd.services.slskd.serviceConfig.umask = 0002;

  virtualisation.oci-containers.containers.soularr = {
    autoStart = true;
    image = "mrusse08/soularr:latest";
    extraOptions = ["--hostuser=streamer"];
    hostname = "soularr";
    environment = {
      TZ = "ETC/UTC";
      SCRIPT_INTERVAL = "300";
    };
    volumes = [
      "${services.slskd.settings.directories.downloads}:/downloads"
      "${dirOf config.age.secrets.soularr.path}:/data"
    ];
  };

  # Plex
  nixarr.plex.enable = true;
}
