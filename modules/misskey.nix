{
  config,
  lib,
  ...
}:
let
  cfg = config.uri.misskey;
in
with lib;
{
  options.uri.misskey = {
    enable = mkEnableOption "Enables and configures misskey instance";
  };

  config = mkIf cfg.enable {
    containers.misskey = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.102.10";
      localAddress = "192.168.102.11";
      hostAddress6 = "fc02::1";
      localAddress6 = "fc02::2";

      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          services.misskey = {
            enable = true;
            settings = {
              port = 3031;
              url = "https://misskey.2dgirls.date";
              id = "aid";
              proxyBypassHosts = [
                "api.deepl.com"
                "api-free.deepl.com"
                "www.recaptcha.net"
                "hcaptcha.com"
                "challenges.cloudflare.com"
              ];
            };
            meilisearch.createLocally = true;
            database.createLocally = true;
            redis.createLocally = true;
          };
          services.meilisearch.package = pkgs.meilisearch;

          networking = {
            firewall.allowedTCPPorts = [ 3031 ];

            # Use systemd-resolved inside the container
            # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
            useHostResolvConf = lib.mkForce false;
          };

          services.resolved.enable = true;

          system.stateVersion = "24.11";
        };
    };
  };
}
