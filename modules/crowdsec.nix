{
  config,
  lib,
  ...
}:
let
  cfg = config.uri.crowdsec;
in
with lib;
{
  options.uri.crowdsec = {
    enable = mkEnableOption "Enables crowdsec with the firewall bouncer";
  };

  config = mkIf cfg.enable {
    services.crowdsec = {
      enable = true;
      autoUpdateService = true;

      hub = {
        collections = [ "crowdsecurity/linux" ];
        parsers = [ "crowdsecurity/whitelists" ];
      };

      settings = {
        config.api.server = {
          listen_uri = "127.0.0.1:8095";
          online_client.credentials_path = "${config.services.crowdsec.settings.config.config_paths.data_dir}/online_api_credentials.yaml";
        };

        acquisitions = [
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
            labels.type = "syslog";
          }
        ];

        parsers.s02Enrich = [
          {
            name = "uri/tailscale-whitelist";
            description = "Never ban tailnet addresses";
            whitelist = {
              reason = "tailscale";
              cidr = [
                "100.64.0.0/10"
                "fd7a:115c:a1e0::/48"
              ];
            };
          }
        ];
      };
    };

    systemd.services.crowdsec.serviceConfig.AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];

    services.crowdsec-firewall-bouncer = {
      enable = true;
      createRulesets = false;
      settings = {
        mode = "nftables";
        nftables = {
          ipv4 = {
            set-only = false;
            priority = -10;
          };
          ipv6 = {
            set-only = false;
            priority = -10;
          };
        };
        nftables_hooks = [
          "input"
          "forward"
        ];
      };
    };
  };
}
