{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.vrchat;
in
with lib;
{
  options.uri.vrchat = {
    enable = mkEnableOption "Enables and configures Unity and vrc-get";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unityhub
      vrc-get
      alcom
      

    ];
    home.file."proyects/unityhub".source = pkgs.unityhub;
  };
}
