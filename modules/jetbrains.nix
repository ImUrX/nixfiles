{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.uri.jetbrains;
in
  with lib; {
    options.uri.jetbrains = {
      enable = mkEnableOption "Enables and configures JetBrains";
    };

    config = mkIf cfg.enable {
      home-manager.users.uri = {...}: {
        home.packages = with pkgs; [
          jetbrains.rider
          jetbrains.idea-ultimate
          jetbrains.clion
          android-studio
        ];
      };
    };
  }
