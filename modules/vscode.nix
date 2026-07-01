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
    programs.vscodium = {
      enable = true;
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
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              publisher = "github";
              name = "copilot-chat";
              version = "0.44.2";
              hash = "sha256-kjLpbA6zUta4K86yEDiLNWvy3kJ3AvF2fncCO/JVl6I=";
            };

            meta = {
              description = "GitHub Copilot Chat is a companion extension to GitHub Copilot that houses experimental chat features";
              downloadPage = "https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat";
              homepage = "https://github.com/features/copilot";
              license = lib.licenses.mit;
              maintainers = [ ];
            };
          })
          # Javascript
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          bradlc.vscode-tailwindcss
          prisma.prisma
          # Rust
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          vadimcn.vscode-lldb
          # Ruby
          shopify.ruby-lsp
          # Haskell
          haskell.haskell
        ]
        ++ (with extensions.open-vsx; [
          floxay.vscode-flatbuffers
          tauri-apps.tauri-vscode
          jeanp413.open-remote-ssh
          blueglassblock.better-json5
          # Ruby
          sorbet.sorbet-vscode-extension
        ]);
    };
  };
}
