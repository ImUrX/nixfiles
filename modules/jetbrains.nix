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
      #jetbrains.rider
      # Add GLFW stuff for being able to dev with Minecraft
      (symlinkJoin {
        name = "idea-ultimate";
        paths = [ jetbrains.idea-ultimate ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/idea-ultimate \
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
      jetbrains.clion
    ];
  };
}
