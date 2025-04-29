{pkgs, ...}: {
  users.users.lal1tx = {
    isNormalUser = true;
    createHome = true;
    extraGroups = ["wheel" "input" "adbusers" "plugdev" "docker" "dialout" "scanner" "lp"]; # Enable ‘sudo’ for the user.
    initialPassword = "eevee123";
  };

  home-manager.users.lal1tx = {
    config,
    lib,
    ...
  }: {
    imports = [
      ../modules/git.nix
      ../modules/vscode.nix
      ../modules/js.nix
      ../modules/java.nix
      ../modules/obs.nix
    ];

    home.stateVersion = "23.05";

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    home.packages = with pkgs; [
      audacity
      netflix
      blender
      anydesk
      xorg.xeyes
      r2modman
      imv
      syncthingtray-minimal
      davinci-resolve
    ];

    # services.easyeffects.enable = true;

    services.syncthing = {
      enable = true;
      tray = {
        enable = false;
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

    cookiecutie.git = {
      enable = true;
      name = "Lal1tx";
      email = "156338803+lal1tx@users.noreply.github.com";
      gpg = false;
    };
    uri.vscode.enable = true;
    uri.java.enable = true;
    uri.javascript.enable = true;
    uri.obs.enable = true;

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    home.shellAliases = {
      love = "echo 'Uri: Te amo Edu <3'";
    };
  };
}
