{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.slsk;
in
with lib;
{
  imports = [
    ./wg-pnp.nix
  ];
  options.uri.slsk = {
    enable = mkEnableOption "Enables and configures slsk";
    downloads = mkOption {
      type = types.str;
      description = "Where to put downloaded files";
    };
    incomplete = mkOption {
      type = types.str;
      description = "Where to put files while being downloaded";
    };
  };

  config = mkIf cfg.enable {
    vpnNamespaces.proton = {
      enable = true;
      wireguardConfigFile = config.age.secrets.vpn-slsk.path;
      accessibleFrom = [
        "192.168.0.0/16"
        "100.100.0.0/16"
        "127.0.0.1"
      ];
      portMappings = [
        {
          from = 5030;
          to = 5030;
        }
      ];
      namespaceAddress = "192.168.16.1";
      namespaceAddressIPv6 = "fd93:9701:1d01::2";
      bridgeAddress = "192.168.16.5";
      bridgeAddressIPv6 = "fd93:9701:1d01::1";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.downloads} 775 root media"
      "d ${cfg.incomplete} 775 root media"
    ];

    services.slskd = {
      enable = true;
      environmentFile = config.age.secrets.soulseek.path;
      # user = "lidarr";
      group = "media";
      domain = null;

      settings = {
        web = {
          authentication = {
            api_keys = {
              soularr = {
                key = "JYRReBr^@shK69J^KYxXG&NTYEXEqSPe1F*DZ4ct@YFcQBzVg5K96E!1&UerFza&";
              };
            };
          };
        };
        global = {
          upload = {
            slots = 10;
            speed_limit = 2048;
          };
        };
        remote_file_management = true;
        directories = {
          downloads = cfg.downloads;
          incomplete = cfg.incomplete;
        };
        shares = {
          directories = [ "/data/media/library/music" ];
          filters = [ ];
        };
        rooms = [ ];
        soulseek = {
          description = "42";
          listen_port = mkForce null;
        };
      };
    };
    systemd.services.slskd = {
      serviceConfig.UMask = "0002";
      vpnConfinement = {
        enable = true;
        vpnNamespace = "proton";
      };
    };

    uri.wg-pnp.slskd = {
      vpnNamespace = "proton";
      runScript = ''
        test=$( ${pkgs.gnugrep}/bin/grep "SLSKD_SLSK_LISTEN_PORT=$new_port" ${config.age.secrets.soulseek.path} || echo rip )
        if [ "$test" = rip ] && [ "$protocol" = tcp ]
        then
          echo "Modifying environment for slskd because new peer port $new_port."
          ${pkgs.gnugrep}/bin/grep 'SLSKD_SLSK_LISTEN_PORT=' ${config.age.secrets.soulseek.path} \
          && ${pkgs.gnused}/bin/sed -ie "\%SLSKD_SLSK_LISTEN_PORT=% c SLSKD_SLSK_LISTEN_PORT=$new_port" ${config.age.secrets.soulseek.path} \
          || printf "\nSLSKD_SLSK_LISTEN_PORT=$new_port" >> ${config.age.secrets.soulseek.path}

          echo "Restarting slskd..."
          systemctl restart slskd.service
        fi
      '';
    };
  };
}
