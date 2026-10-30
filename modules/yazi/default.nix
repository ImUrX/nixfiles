{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.yazi;
  mapFetchers =
    {
      types,
      run,
      group,
      key ? "url",
      prio ? "normal",
    }:
    map (x: {
      ${key} = x;
      inherit run prio;
    }) types;
in
with lib;
{
  options.uri.yazi = {
    enable = mkEnableOption "Enables and configures yazi";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xpdf # pdf utilities
      duckdb # db viewer
      ripdrag # terminal dragging
    ];

    programs.yazi = {
      enable = true;
      initLua = ./init.lua;
      plugins = {
        inherit (pkgs.yaziPlugins)
          git
          easyjump
          diff
          chmod
          restore
          duckdb
          starship
          drag
          wl-clipboard
          office
          smart-filter
          ;
      };
      settings = {
        yazi = {
          plugin = {
            prepend_fetches = mapFetchers {
              types = [
                "*"
                "*/"
              ];
              run = "git";
              group = "git";
            };
            prepend_previewers = [
              {
                url = "*.{csv,tsv,json,parquet,txt,xlsx,db,duckdb}";
                run = "duckdb";
              }
              {
                mime = "application/{openxmlformats-officedocument.*,oasis.opendocument.*,msword}";
                run = "office";
              }
            ];

            prepend_preloaders = [
              {
                url = "*.{csv,tsv,json,parquet,txt,xlsx}";
                run = "duckdb";
                prio = "high";
              }
              {
                mime = "application/{openxmlformats-officedocument.*,oasis.opendocument.*,msword}";
                run = "office";
              }
            ];
          };
        };

        keymap = {
          mgr = {
            prepend_keymap = [
              {
                on = [ "<C-d>" ];
                run = "plugin drag";
                desc = "Drag Files";
              }
              {
                on = [ "<C-y>" ];
                run = [ "plugin wl-clipboard" ];
                desc = "Copy with Wayland";
              }
              {
                on = "F";
                run = "plugin smart-filter";
                desc = "Smart filter";
              }
              {
                on = [ "i" ];
                run = "plugin easyjump";
                desc = "easyjump";
              }

              #duckdb
              {
                on = "H";
                run = "plugin duckdb -1";
                desc = "Scroll one column to the left";
              }
              {
                on = "L";
                run = "plugin duckdb +1";
                desc = "Scroll one column to the right";
              }
              {
                on = [
                  "g"
                  "o"
                ];
                run = "plugin duckdb -open";
                desc = "open with duckdb";
              }
              {
                on = [
                  "g"
                  "u"
                ];
                run = "plugin duckdb -ui";
                desc = "open with duckdb ui";
              }
            ];
          };
        };
      };
    };
  };
}
