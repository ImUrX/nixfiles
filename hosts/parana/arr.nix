{
  config,
  pkgs,
  lib,
  ...
}: {
  nixarr.enable = true;

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

  # systemd.timers."transmission-port-forwarding" = {
  #   wantedBy = ["timers.target"];
  #   after = ["transmission.service"];
  #   timerConfig = {
  #     OnBootSec = "45s";
  #     OnUnitActiveSec = "45s";
  #     Unit = "transmission-port-forwarding.service";
  #   };
  # };

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

        result="$(${pkgs.libnatpmp}/bin/natpmpc -a 1 0 "$protocol" 60 -g 10.2.0.1)"
        echo "$result"

        new_port="$(echo "$result" | ${pkgs.ripgrep}/bin/rg --only-matching --replace '$1' 'Mapped public port (\d+) protocol ... to local port 0 lifetime 60')"
        old_port="$(cat "$port_file")"
        echo "Mapped new $protocol port $new_port, old one was $old_port."
        echo "$new_port" >"$port_file"

        if [ "$protocol" = tcp ]
        then
          echo "Telling transmission to listen on peer port $new_port."
          ${pkgs.transmission}/bin/transmission-remote --port "$new_port"
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
}
