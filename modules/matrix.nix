{
  config,
  lib,
  ...
}:
let
  cfg = config.uri.matrix;
in
with lib;
{
  options.uri.matrix = {
    enable = mkEnableOption "Enables and configures matrix homeserver";
  };

  config = mkIf cfg.enable {
    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        server_name = "imurx.org";
        registration_token_file = "${config.age.secrets.matrix.path}";
        allow_registration = true;
        database_backup_path = "/data/backup/tuwunel";
        trusted_servers = [
          "matrix.org"
          "tchncs.de"
          "nixos.org"
        ];
      };
    };
  };
}
