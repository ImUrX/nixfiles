{pkgs, ...}: {
  users.users.uri = {
    isNormalUser = true;
    createHome = true;
    extraGroups = ["wheel" "input" "adbusers" "plugdev" "docker" "dialout" "audio" "scanner" "lp" "wireshark"]; # Enable ‘sudo’ for the user.
    initialPassword = "eevee123";
  };
  users.groups.plugdev = {};

  environment.variables.EXILED_References = "/home/uri/referenciasdelicht";
  environment.variables.SL_REFERENCES = "/home/uri/referenciasdelicht";

  services.udev.packages = [
    pkgs.platformio-core
    pkgs.openocd
  ];

  programs.wireshark.enable = true;

  home-manager.users.uri = {
    config,
    lib,
    ...
  }: {
    imports = [
      ./modules/git.nix
      ./modules/vscode.nix
      ./modules/jetbrains.nix
      ./modules/js.nix
      ./modules/java.nix
      ./modules/rust.nix
      ./modules/obs.nix
    ];

    home.stateVersion = "23.05";

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    home.packages = with pkgs; [
      blender-hip
      thunderbird
      anydesk
      termius
      inkscape-with-extensions
      xorg.xeyes
      fractal
      flatpak-builder
      python3Full
      python311Packages.toml
      python311Packages.aiohttp
      r2modman
      imv
      dotnet-sdk_8
      mono
      xivlauncher
      alsa-scarlett-gui
      syncthingtray-minimal
      cosign
      openmw
      pupdate
      calibre
      platformio
      dualsensectl
      pcsx2
      wowup-cf
    ];

    # services.arrpc.enable = true;
    # services.easyeffects.enable = true;

    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };

    home.sessionVariables = {
      MESA_DISK_CACHE_SINGLE_FILE = "1";
    };

    # dconf.settings = {
    #   "org/gnome/desktop/input-sources" = {
    #     show-all-sources = true;
    #     sources = [
    #       (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
    #       (lib.hm.gvariant.mkTuple ["xkb" "latam"])
    #     ];
    #     xkb-options = ["terminate:ctrl_alt_bksp"];
    #   };
    #   "org/gnome/shell" = {
    #     disable-user-extensions = false;

    #     # `gnome-extensions list` for a list
    #     enabled-extensions = [
    #       "appindicatorsupport@rgcjonas.gmail.com"
    #     ];
    #   };
    # };

    qt.platformTheme = "kde";

    xdg.enable = true;
    # xdg.mimeApps = {
    #   enable = true;
    #   defaultApplications = {
    #     "image" = ["imv.desktop"];
    #     "video" = ["mpv.desktop"];
    #     "text/html" = ["firefox.desktop"];
    #     "x-scheme-handler/http" = ["firefox.desktop"];
    #     "x-scheme-handler/https" = ["firefox.desktop"];
    #     "x-scheme-handler/humble" = ["Humble-scheme-handler.desktop"];
    #     "x-scheme-handler/ror2mm" = ["r2modman.desktop"];
    #     "x-scheme-handler/termius" = ["Termius.desktop"];
    #     "x-scheme-handler/ssh" = ["ktelnetservice5.desktop"];
    #     "x-scheme-handler/heroic" = ["com.heroicgameslauncher.hgl.desktop"];
    #   };
    # };

    programs.direnv.enable = true;
    programs.direnv.enableBashIntegration = true;
    programs.bash.enable = true;

    # programs.doom-emacs = {
    #   # emacsPackages = with inputs.emacs-overlay.packages.${config.nixpkgs.system};
    #   #   emacsPackagesFor emacsGit;
    #   enable = true;
    #   doomPrivateDir = ./doom.d; # Directory containing your config.el, init.el
    #   # and packages.el files
    # };

    cookiecutie.git.enable = true;
    # cookiecutie.git.signingkey = "13E59DEACC71A51D";
    uri.vscode.enable = true;
    uri.jetbrains.enable = true;
    uri.rust.enable = true;
    uri.java.enable = true;
    uri.javascript.enable = true;
    uri.obs.enable = true;
    # uri.hyprland.enable = true;

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    home.shellAliases = {
      love = "echo 'Edu: Te amo Uri <3'";
      pupdate = "pupdate -p /run/media/uri/analogue/";
    };
  };
}
