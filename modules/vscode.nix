{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.uri.vscode;
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
in
  with lib; {
    options.uri.vscode = {
      enable = mkEnableOption "Enables and configures vscode";
    };

    config = mkIf cfg.enable {
      home-manager.users.uri = {...}: {
        programs.vscode = {
          enable = true;
          package = pkgs.vscodium;
          extensions = with pkgs.vscode-extensions;
            [
              ms-vsliveshare.vsliveshare
              jnoortheen.nix-ide
              # mkhl.direnv
              arrterian.nix-env-selector
              kamadorueda.alejandra
              eamodio.gitlens
              redhat.vscode-xml
              editorconfig.editorconfig
              oderwat.indent-rainbow
              davidanson.vscode-markdownlint
              redhat.vscode-yaml
              # Javascript
              dbaeumer.vscode-eslint
              esbenp.prettier-vscode
              bradlc.vscode-tailwindcss
              mskelton.npm-outdated
              # Rust
              matklad.rust-analyzer
              tamasfe.even-better-toml
              serayuzgur.crates
            ]
            ++ (with extensions.open-vsx; [
              floxay.vscode-flatbuffers
              tauri-apps.tauri-vscode
            ])
            ++ (with extensions.vscode-marketplace; [
              macabeus.vscode-fluent
            ]);
        };
      };
    };
  }
