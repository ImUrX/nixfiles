{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.uri.ags;
in
  with lib; {
    options.uri.ags = {
      enable = mkEnableOption "Enables and configures AGS";
    };
    imports = [
      inputs.ags.homeManagerModules.default
    ];

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        ollama
        pywal
        sassc
        # (python311.withPackages (p: [
        #   p.material-color-utilities
        #   p.pywayland
        # ]))
      ];

      programs.ags = {
        enable = true;
        configDir = null; # if ags dir is managed by home-manager, it'll end up being read-only. not too cool.
        # configDir = ./.config/ags;

        extraPackages = with pkgs; [
          gtksourceview
          gtksourceview4
          ollama
          python311Packages.material-color-utilities
          python311Packages.pywayland
          pywal
          sassc
          webkitgtk
          webp-pixbuf-loader
          ydotool
        ];
      };
    };
  }
