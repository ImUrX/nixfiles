{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.uri.vscode;
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
in
with lib;
{
  options.uri.vscode = {
    enable = mkEnableOption "Enables and configures vscode";
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.extensions =
        with pkgs.vscode-extensions;
        [
          ms-vsliveshare.vsliveshare
          jnoortheen.nix-ide
          mkhl.direnv
          # arrterian.nix-env-selector
          eamodio.gitlens
          redhat.vscode-xml
          editorconfig.editorconfig
          oderwat.indent-rainbow
          davidanson.vscode-markdownlint
          redhat.vscode-yaml
          fill-labs.dependi
          # Javascript
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          bradlc.vscode-tailwindcss
          # Rust
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          vadimcn.vscode-lldb
        ]
        ++ (with extensions.open-vsx; [
          floxay.vscode-flatbuffers
          tauri-apps.tauri-vscode
          jeanp413.open-remote-ssh
          blueglassblock.better-json5
        ])
        ++ (with extensions.vscode-marketplace; [
          macabeus.vscode-fluent
          object-object.hex-casting
        ]);
    };
  };
}
