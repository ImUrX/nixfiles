{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.uri.vscode;
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
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "vscode-fluent";
                publisher = "macabeus";
                version = "1.0.0";
                sha256 = "814e374452e9e9e99896893ad1c1de2dae2486285a668f985c66ef25eb08a9f2";
              }
              {
                name = "flatbuffers";
                publisher = "gaborv";
                version = "0.1.0";
                sha256 = "dd6b26d628ade5e0b99e32c52db1a184060d6299c0589afbe0e96c46042a0acb";
              }
            ];
        };
      };
    };
  }
