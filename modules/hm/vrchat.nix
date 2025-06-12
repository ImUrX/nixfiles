{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.vrchat;
  unityhub = pkgs.unityhub.override {
    extraPkgs = pkgs: [
      pkgs.corefonts
      pkgs.ipafont
    ];
  };
in
with lib;
{
  options.uri.vrchat = {
    enable = mkEnableOption "Enables and configures Unity and vrc-get";
  };

  config = mkIf cfg.enable {
    home.packages = [
      unityhub
      pkgs.vrc-get
      pkgs.alcom
      # https://gist.github.com/nil-vr/09f6ebf470701d007553cf0de7c2c3ee
      (pkgs.stdenvNoCC.mkDerivation rec {
        pname = "unity";
        version = "2022.3.22f1";
        dontFixup = true;

        unitySrc = pkgs.fetchurl {
          url = "https://download.unity3d.com/download_unity/887be4894c44/LinuxEditorInstaller/Unity-2022.3.22f1.tar.xz";
          hash = "sha256-eE//d2kFHA9p7bA52NCUMeeuQASmSh20QDcJ3biKpQY=";
        };
        androidSupportSrc = pkgs.fetchurl {
          url = "https://download.unity3d.com/download_unity/887be4894c44/MacEditorTargetInstaller/UnitySetup-Android-Support-for-Editor-2022.3.22f1.pkg";
          hash = "sha256-Vqk8HgnFsUzjLvjIhIdJTLFHpyE6UDhwR7hN7/Jjpak=";
        };
        windowsSupportSrc = pkgs.fetchurl {
          url = "https://download.unity3d.com/download_unity/887be4894c44/MacEditorTargetInstaller/UnitySetup-Windows-Mono-Support-for-Editor-2022.3.22f1.pkg";
          hash = "sha256-iBGBpsg3IwooTqQSC/y14qq5QLuQEOvftQ07iGXCBZ0=";
        };

        nativeBuildInputs = [
          pkgs.cpio
          pkgs.xarMinimal
        ];
        buildInputs = [ unityhub.fhsEnv ];

        unpackPhase = ''
                  mkdir android
          	xar -C android -xf "${androidSupportSrc}"
                  mkdir windows
          	xar -C windows -xf "${windowsSupportSrc}"
        '';

        installPhase = ''
                  # This Editor/version/Editor path helps Unity Hub recognize the version of the editor.
                  mkdir -p "$out/bin" "$out/Editor/${version}/Editor/Data/PlaybackEngines/AndroidPlayer" "$out/Editor/${version}/Editor/Data/PlaybackEngines/WindowsStandaloneSupport"

          	tar -C "$out/Editor/${version}" -xf "${unitySrc}"
          	gzip -d < android/TargetSupport.pkg.tmp/Payload | cpio -iD "$out/Editor/${version}/Editor/Data/PlaybackEngines/AndroidPlayer"
          	gzip -d < windows/TargetSupport.pkg.tmp/Payload | cpio -iD "$out/Editor/${version}/Editor/Data/PlaybackEngines/WindowsStandaloneSupport"

          	# Create unity wrapper script
                  cat > "$out/bin/unity" <<-EOF
          	#!/bin/sh
                  exec -a "$out/Editor/${version}/Editor/Unity" "${unityhub.fhsEnv}/bin/unityhub-fhs-env" "$out/Editor/${version}/Editor/Unity" "\$@"
          	EOF
          	chmod a+x "$out/bin/unity"

          	# Fix font fallback
          	cat > "$out/Editor/${version}/Editor/Data/Resources/fontsettings.txt" <<-EOF
          	English|default=Inter, IPAPGothic, Verdana, Tahoma
          	English|Inter-Regular=Inter, IPAPGothic, Verdana, Tahoma
          	English|Inter-SemiBold=Inter, IPAPGothic, Verdana, Tahoma
          	English|Inter-Small=Inter, IPAPGothic, Verdana, Tahoma
          	English|Inter-Italic=Inter, IPAPGothic, Verdana, Tahoma
          	English|Inter-SemiBoldItalic=Inter, IPAPGothic, Verdana, Tahoma
          	EOF
        '';
      })
    ];

    home.file."proyects/unityhub".source = unityhub;
  };
}
