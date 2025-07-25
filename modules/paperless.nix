{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.uri.paperless;
in
with lib;
{
  options.uri.paperless = {
    enable = mkEnableOption "Enables and configures paperless-ngx";
  };

  config = mkIf cfg.enable {
    containers.paperless = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";

      bindMounts."/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
      bindMounts."/data/backup/paperless".isReadOnly = false;

      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          imports = [ inputs.agenix.nixosModules.default ]; # import agenix-module into the nixos-container
          age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # isn't set automatically when openssh is not setup
          age.secrets.passwd.file = ../secrets/paperless-passwd.age;

          systemd.services.protonmail-bridge = {
            description = "protonmail bridge";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            environment = {
              HOME = "/root";
            };

            serviceConfig = {
              ExecStart = "${lib.getExe pkgs.protonmail-bridge} -n";
              Restart = "always";
              CPUQuota = "50%";
            };
          };
          services.nginx = {
            enable = true;
            streamConfig = ''
              upstream proton {
                server 127.0.0.1:1025;
              }
              server {
                listen 192.168.42.69:1025;
                proxy_pass proton;
              }
            '';
          };
          environment.systemPackages = [ pkgs.protonmail-bridge ];

          services.tika.enable = true;

          services.postgresql = {
            enable = true;
            ensureDatabases = [ "paperless" ];
            authentication = pkgs.lib.mkOverride 10 ''
              #type database  DBuser  auth-method
              local all       all     trust
            '';
          };

          services.postgresqlBackup = {
            enable = true;
            compression = "zstd";
            compressionLevel = 11;
            location = "/data/backup/paperless";
          };

          services.paperless = {
            enable = true;
            passwordFile = config.age.secrets.passwd.path;
            address = "0.0.0.0";
            settings = {
              PAPERLESS_OCR_LANGUAGE = "spa+eng+nld";
              PAPERLESS_TIKA_ENABLED = true;
              PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://192.168.100.10:3000";

              PAPERLESS_URL = "https://paper.2dgirls.date";
              PAPERLESS_CSRF_TRUSTED_ORIGINS = "http://192.168.100.11:28981";
              PAPERLESS_ALLOWED_HOSTS = "192.168.100.11";
              PAPERLESS_CORS_ALLOWED_HOSTS = "http://192.168.100.11:28981";

              PAPERLESS_TRUSTED_PROXIES = "172.30.33.0/24";
              PAPERLESS_USE_X_FORWARD_HOST = true;

              PAPERLESS_DBHOST = "/run/postgresql";
              PAPERLESS_DBUSER = "postgres";
            };
          };

          networking = {
            firewall.allowedTCPPorts = [ 28981 ];

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
