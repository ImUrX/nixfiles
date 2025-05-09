{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.rust;
in
with lib;
{
  options.uri.rust = {
    enable = mkEnableOption "Enables and configures Rust toolchains";
  };

  config = mkIf cfg.enable {
    home.file.".rustup/settings.toml".source = (pkgs.formats.toml { }).generate "rustup-default.toml" {
      default_toolchain = "stable";
      profile = "default";
      version = "12";
    };

    home.packages = with pkgs; [
      rustup
      crate2nix
    ];
  };
}
