{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.uri.java;
in
  with lib; {
    options.uri.java = {
      enable = mkEnableOption "Enables and configures Java toolchains";
    };

    config = mkIf cfg.enable {
      home.file."jdks/openjdk8".source = pkgs.jdk8;
      home.file."jdks/openjdk11".source = pkgs.jdk11;
      home.file."jdks/openjdk17".source = pkgs.jdk17;
      home.file."jdks/openjdk".source = pkgs.jdk;

      home.packages = with pkgs; [
        jdk
        gradle
        gradle-completion
        maven
      ];
    };
  }
