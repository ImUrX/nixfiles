{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.vrchat;
  unityhub = (pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "unityhub";
        version = "3.12.1";

        src = pkgs.fetchurl {
          url = "https://hub-dist.unity3d.com/artifactory/hub-debian-prod-local/pool/main/u/unity/unityhub_amd64/unityhub-amd64-${finalAttrs.version}.deb";
          sha256 = "sha256-Zpzl3H8cgVmPqpRAakL3m12OZ04Ddzpm+2krkuEkwrk=";
        };

        nativeBuildInputs = [
          pkgs.dpkg
          pkgs.makeWrapper
        ];

        fhsEnv = pkgs.buildFHSEnv {
          pname = "${finalAttrs.pname}-fhs-env";
          inherit (finalAttrs) version;
          runScript = "";

          targetPkgs =
            pkgs: with pkgs; [
              # Unity Hub binary dependencies
              xorg.libXrandr
              xdg-utils

              # GTK filepicker
              gsettings-desktop-schemas
              hicolor-icon-theme

              # Bug Reporter dependencies
              fontconfig
              freetype
              lsb-release
            ];

          multiPkgs =
            pkgs: with pkgs; [
              # Unity Hub ldd dependencies
              cups
              gtk3
              expat
              libxkbcommon
              lttng-ust_2_12
              krb5
              alsa-lib
              nss
              libdrm
              libgbm
              nspr
              atk
              dbus
              at-spi2-core
              pango
              xorg.libXcomposite
              xorg.libXext
              xorg.libXdamage
              xorg.libXfixes
              xorg.libxcb
              xorg.libxshmfence
              xorg.libXScrnSaver
              xorg.libXtst

              # Unity Hub additional dependencies
              libva
              openssl
              cairo
              libnotify
              libuuid
              libsecret
              udev
              libappindicator
              wayland
              cpio
              icu
              libpulseaudio

              # Unity Editor dependencies
              libglvnd # provides ligbl
              xorg.libX11
              xorg.libXcursor
              glib
              gdk-pixbuf
              libxml2
              zlib
              clang
              git # for git-based packages in unity package manager

              # Unity Editor 2019 specific dependencies
              # xorg.libXi
              # xorg.libXrender
              # gnome2.GConf
              # libcap

              # Unity Editor 6000 specific dependencies
              harfbuzz
              vulkan-loader

              # Unity Bug Reporter specific dependencies
              xorg.libICE
              xorg.libSM

              # Fonts used by built-in and third party editor tools
              corefonts
              dejavu_fonts
              liberation_ttf
            ];
        };

        unpackCmd = "dpkg -x $curSrc src";

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          mv opt/ usr/share/ $out

          # `/opt/unityhub/unityhub` is a shell wrapper that runs `/opt/unityhub/unityhub-bin`
          # Which we don't need and overwrite with our own custom wrapper
          makeWrapper ${finalAttrs.fhsEnv}/bin/${finalAttrs.pname}-fhs-env $out/opt/unityhub/unityhub \
            --add-flags $out/opt/unityhub/unityhub-bin \
            --argv0 unityhub

          # Link binary
          mkdir -p $out/bin
          ln -s $out/opt/unityhub/unityhub $out/bin/unityhub

          # Replace absolute path in desktop file to correctly point to nix store
          substituteInPlace $out/share/applications/unityhub.desktop \
            --replace /opt/unityhub/unityhub $out/opt/unityhub/unityhub

          runHook postInstall
        '';

        passthru.updateScript = ./update.sh;

        meta = with lib; {
          description = "Official Unity3D app to download and manage Unity Projects and installations";
          homepage = "https://unity.com/";
          downloadPage = "https://unity.com/unity-hub";
          changelog = "https://unity.com/unity-hub/release-notes";
          license = licenses.unfree;
          maintainers = with maintainers; [
            tesq0
            huantian
          ];
          platforms = [ "x86_64-linux" ];
          sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        };
      }));
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
      

    ];
    home.file."proyects/unityhub".source = unityhub;
  };
}
