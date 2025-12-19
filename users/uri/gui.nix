{ pkgs, ... }:
{
  imports = [
    ../../modules/vscode.nix
    ../../modules/jetbrains.nix
    ../../modules/obs.nix
    ../../modules/hm/vrchat.nix
    ../../modules/hm/vr.nix
  ];

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  home.packages = with pkgs; [
    blender-hip
    thunderbird
    anydesk
    # termius
    inkscape-with-extensions
    xorg.xeyes
    fluffychat
    flatpak-builder
    python3
    r2modman
    imv
    dotnet-sdk_8
    mono
    xivlauncher
    alsa-scarlett-gui
    syncthingtray-minimal
    openmw
    pupdate
    calibre
    platformio
    dualsensectl
    pcsx2
    wowup-cf
    krita
    devenv
    rubyPackages_3_5.ruby-lsp
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

  # programs.doom-emacs = {
  #   # emacsPackages = with inputs.emacs-overlay.packages.${config.nixpkgs.system};
  #   #   emacsPackagesFor emacsGit;
  #   enable = true;
  #   doomPrivateDir = ./doom.d; # Directory containing your config.el, init.el
  #   # and packages.el files
  # };

  cookiecutie.git.gpg = true;
  cookiecutie.git.signingkey = "13E59DEACC71A51D";
  uri.jetbrains.enable = true;
  uri.obs.enable = true;
  uri.vscode.enable = true;
  uri.vrchat.enable = true;
  uri.vr.enable = true;
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
