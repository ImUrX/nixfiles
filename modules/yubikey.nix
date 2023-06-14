{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.uri.yubi;
in
  with lib; {
    options.uri.yubi = {
      enable = mkEnableOption "Enables and configures Yubikey usage";
    };

    config = mkIf cfg.enable {
      services.udev.packages = [pkgs.yubikey-personalization];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      security.pam.yubico = {
        enable = true;
        mode = "challenge-response";
      };
      services.pcscd.enable = true;
    };
  }
