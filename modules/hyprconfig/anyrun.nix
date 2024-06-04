{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.uri.anyrun;
in
  with lib; {
    options.uri.anyrun = {
      enable = mkEnableOption "Enables and configures Anyrun";
    };
    imports = [
      inputs.anyrun.homeManagerModules.default
    ];

    config = mkIf cfg.enable {
      programs.anyrun = {
        enable = true;
        config = {
          plugins = with inputs.anyrun.packages.${pkgs.system}; [
            applications
            randr
            rink
            shell
            symbols
          ];

          width.fraction = 0.3;
          y.absolute = 15;
          hidePluginInfo = true;
          closeOnClick = true;
        };
      };
    };
  }
