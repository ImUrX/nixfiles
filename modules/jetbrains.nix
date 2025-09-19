{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.jetbrains;
in
with lib;
{
  options.uri.jetbrains = {
    enable = mkEnableOption "Enables and configures JetBrains";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Add GLFW stuff for being able to dev with Minecraft
      (symlinkJoin {
        name = "idea-community";
        paths = [ jetbrains.idea-community ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/idea-community \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              libpulseaudio
              libGL
              glfw
              openal
              stdenv.cc.cc.lib
            ]
          }"
        '';
      })
    ];
  };
}
