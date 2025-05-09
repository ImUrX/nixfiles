{
  config,
  lib,
  ...
}:
let
  cfg = config.uri.immich;
in
with lib;
{
  options.uri.immich = {
    enable = mkEnableOption "Enables and configures immich";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /data/backup/immich 770 immich immich"
      "d /data/media/immich 770 immich immich"
    ];
    containers.immich = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.101.10";
      localAddress = "192.168.101.11";
      hostAddress6 = "fc01::1";
      localAddress6 = "fc01::2";

      bindMounts."/data/media/immich".isReadOnly = false;

      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          services.immich = {
            enable = true;
            host = "0.0.0.0";
            mediaLocation = "/data/media/immich";
            settings = {
              server.externalDomain = "https://img.2dgirls.date";
            };
          };

          networking = {
            firewall.allowedTCPPorts = [ 2283 ];

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
