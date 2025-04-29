{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.uri.javascript;
in
  with lib; {
    options.uri.javascript = {
      enable = mkEnableOption "Enables and configures Javascript toolchains";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        deno
        nodejs
      ];
    };
  }
