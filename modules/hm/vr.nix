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
    home.packages =
      with pkgs;
      let
        wlxRuntimePackages = [
          cage
          playerctl
          eepyxr
        ];
      in
      [
        # opencomposite
        # xrizer
        (writeShellScriptBin "wlx-overlay-s" ''
          env PATH="${lib.makeBinPath wlxRuntimePackages}:$PATH" ${
            wlx-overlay-s.overrideAttrs (oldAttrs: {
              cargoBuildFeatures = [ "uidev" ];
              buildInputs = oldAttrs.buildInputs ++ [
                vulkan-loader
              ];

              postFixup = ''
                patchelf $out/bin/${oldAttrs.pname} \
                  --add-needed ${wayland}/lib/libwayland-client.so \
                  --add-needed ${vulkan-loader}/lib/libvulkan.so
              '';
            })
          }/bin/wlx-overlay-s "$@"
        '')
        wayvr-dashboard
        slimevr

        bs-manager
      ]
      ++ wlxRuntimePackages;

    # "${pkgs.opencomposite}/lib/opencomposite"
    # xdg.configFile."openvr/openvrpaths.vrpath" = {
    #   source = pkgs.writeText "openvrpaths.vrpath" ''
    #     {
    #       "config" :
    #       [
    #         "~/.local/share/Steam/config"
    #       ],
    #       "external_drivers" : null,
    #       "jsonid" : "vrpathreg",
    #       "log" :
    #       [
    #         "~/.local/share/Steam/logs"
    #       ],
    #       "runtime" :
    #       [
    #         "${pkgs.xrizer}/lib/xrizer"
    #       ],
    #       "version" : 1
    #     }
    #   '';
    #   # force = true;
    # };

    xdg.configFile."wlxoverlay/watch.yaml".source = ./config/wlxoverlay/watch.yaml;
    xdg.configFile."wlxoverlay/wayvr.yaml".source = ./config/wlxoverlay/wayvr.yaml;
  };
}
