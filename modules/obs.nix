{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.obs;
in
with lib;
{
  options.uri.obs = {
    enable = mkEnableOption "Enables and configures OBS streaming";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ffmpeg_7-full
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-good
      gst_all_1.gst-vaapi
    ];
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      obs-gstreamer
      obs-pipewire-audio-capture
    ];
  };
}
