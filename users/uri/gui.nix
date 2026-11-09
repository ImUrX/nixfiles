{ pkgs, ... }:
{
  imports = [
    ../../modules/hm/vscode.nix
    ../../modules/hm/jetbrains.nix
    ../../modules/hm/obs.nix
    ../../modules/hm/vrchat.nix
    ../../modules/hm/vr.nix
  ];
  home.packages =
    with pkgs;
    [
      # Art
      # pkgsRocm.blender
      blender
      inkscape-with-extensions
      krita
      autodesk-fusion
      pixelorama

      # Social
      thunderbird
      dino

      # Dev
      flatpak-builder
      dotnet-sdk_8
      python312
      mono
      rubyPackages_3_5.ruby-lsp
      devenv
      platformio

      # Game
      openmw
      pupdate
      archipelago
      dualsensectl
      deadlock-mod-manager

      # Util
      anydesk
      imv
      alsa-scarlett-gui
      syncthingtray-minimal
      calibre
    ]
    ++ (
      if pkgs.system == "x86_64-linux" then
        with pkgs;
        [
          # Social
          fluffychat

          # Game
          (olympus.override {
            celesteWrapper = pkgs.steam-run;
          })
          xivlauncher
          melonloader-installer
          wowup-cf
          r2modman
          # inputs.nix-citizen.packages.${system}.rsi-launcher

          # Util
          termius
          upscayl
        ]
      else
        [ ]
    );

  # Add service for syncthing to be able to load
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait";
    };
  };

  services.easyeffects = {
    enable = true;
    package = pkgs.easyeffects.override {
      # Newer rnnoise model
      rnnoise =
        (pkgs.rnnoise.override {
          modelUrl = "https://media.xiph.org/rnnoise/models/rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz";
          modelHash = "sha256-CodV+OLYNO/2pUcU7MfXX5ky6EXfNfi1m8UqfP5uizc=";
        }).overrideAttrs
          {
            src = pkgs.fetchFromGitLab {
              domain = "gitlab.xiph.org";
              owner = "xiph";
              repo = "rnnoise";
              rev = "70f1d256acd4b34a572f999a05c87bf00b67730d";
              sha256 = "sha256-fkSy7Sqnx0yLfGLciHf8PaptzFVzFAeRrhE4R5z8hSw=";
            };
            patches = [ ];
          };
    };
  };

  qt.platformTheme = "kde";

  xdg.enable = true;

  # Dev stuff
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    themeFile = "Yotei_Midnight";
    settings = {
      scrollback_lines = 10000;
      custom_shaders = "cursor-trail-motion-blur dim-inactive-windows";
      cursor_trail = 1;
    };
  };
  uri.jetbrains.enable = true;
  uri.vscode.enable = true;
  cookiecutie.git.gpg = true;
  cookiecutie.git.signingkey = "FC190DCC1967F4C5";

  # Game stuff
  uri.obs.enable = true;
  uri.vrchat.enable = pkgs.system == "x86_64-linux";
  uri.vr.enable = pkgs.system == "x86_64-linux";
  # uri.hyprland.enable = true;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    NIXOS_OZONE_WL = "1";
    MESA_DISK_CACHE_SINGLE_FILE = "1";

    EXILED_References = "/home/uri/referenciasdelicht";
    SL_REFERENCES = "/home/uri/referenciasdelicht";
  };
  home.shellAliases = {
    pupdate = "pupdate -p /run/media/uri/analogue/";
  };
}
