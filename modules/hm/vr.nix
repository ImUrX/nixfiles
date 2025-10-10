{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.vr;
in
with lib;
{
  options.uri.vr = {
    enable = mkEnableOption "Enables and configures VR for Linux";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # opencomposite
      # xrizer
      wlx-overlay-s
      wayvr-dashboard
      slimevr
      eepyxr

      bs-manager
    ];

    xdg.configFile = {
      "wlxoverlay/watch.yaml".source =
        with pkgs;
        (replaceVars ./config/wlxoverlay/watch.yaml {
          playerctl = "${playerctl}/bin/playerctl";
          wpctl = "${wireplumber}/bin/wpctl";
          DEFAULT_AUDIO_SINK = null;
        });
      "wlxoverlay/wayvr.yaml".source =
        with pkgs;
        (replaceVars ./config/wlxoverlay/wayvr.yaml {
          wayvr = "${wayvr-dashboard}/bin/wayvr-dashboard";
          slimevr = "${slimevr}/bin/slimevr";
          console = "${kdePackages.konsole}/bin/konsole";
          firefox = "${firefox}/bin/firefox";
          cage = "${cage}/bin/cage";
          btop = "${btop}/bin/btop";
        });
      # "${pkgs.xrizer}/lib/xrizer"
      "openvr/openvrpaths.vrpath".text = ''
        {
          "config" :
          [
            "~/.local/share/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" :
          [
            "~/.local/share/Steam/logs"
          ],
          "runtime" :
          [
            "${pkgs.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
    };
  };
}
