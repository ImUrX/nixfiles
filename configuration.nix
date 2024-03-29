# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./modules/nix.nix
    ./modules/sound
    ./fonts.nix
    ./modules/git.nix
    ./modules/steam.nix
    ./modules/vscode.nix
    ./modules/jetbrains.nix
    ./modules/js.nix
    ./modules/java.nix
    ./modules/rust.nix
    ./modules/obs.nix
    ./modules/yubikey.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    sandbox = true;
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  virtualisation.waydroid.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Argentina/Buenos_Aires";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  #.x.enable = true;
  programs.xwayland.enable = true;
  services.xserver.enable = true;
  # services.xserver.videoDrivers = ["amdgpu"];

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.defaultSession = "gnome";

  # systemd.services."user@1000".serviceConfig.LimitNOFILE = "32768";
  # security.pam.loginLimits = [
  #   {
  #     domain = "*";
  #     item = "nofile";
  #     type = "-";
  #     value = "32768";
  #   }
  #   {
  #     domain = "*";
  #     item = "memlock";
  #     type = "-";
  #     value = "32768";
  #   }
  # ];

  # Enable KDE
  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.defaultSession = "plasma";
  programs.dconf.enable = true;

  environment.variables.EXILED_References = "/home/uri/referenciasdelicht";
  environment.variables.SL_REFERENCES = "/home/uri/referenciasdelicht";

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    postscript-lexmark
  ];

  # Enable sound.
  #sound.enable = true;
  #services.pipewire.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  cookiecutie.sound.pipewire.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.uri = {
    isNormalUser = true;
    createHome = true;
    extraGroups = ["wheel" "input" "adbusers" "plugdev" "docker" "dialout"]; # Enable ‘sudo’ for the user.
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  home-manager.users.uri = {
    config,
    lib,
    ...
  }: {
    home.stateVersion = "23.05";
    # imports = [inputs.nix-doom-emacs.hmModule];

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = ["graphical-session-pre.target"];
      };
    };

    home.packages = with pkgs; [
      blender-hip
      thunderbird
      vesktop
      anydesk
      termius
      inkscape-with-extensions
      xorg.xeyes
      prismlauncher
      element-desktop
      mpv
      qbittorrent
      spotify-qt
      spotify
      appimage-run
      flatpak-builder
      python3Full
      python310Packages.toml
      python310Packages.aiohttp
      gimp
      aegisub
      # old electron in EoL
      # r2modman
      unityhub
      imv
      dotnet-sdk_7
      mono
      xivlauncher
      alsa-scarlett-gui
      syncthingtray-minimal
    ];

    services.easyeffects.enable = true;

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
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image" = ["imv.desktop"];
        "video" = ["mpv.desktop"];
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/humble" = ["Humble-scheme-handler.desktop"];
        "x-scheme-handler/ror2mm" = ["r2modman.desktop"];
        "x-scheme-handler/termius" = ["Termius.desktop"];
        "x-scheme-handler/ssh" = ["ktelnetservice5.desktop"];
        "x-scheme-handler/heroic" = ["com.heroicgameslauncher.hgl.desktop"];
      };
    };

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

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
    home.shellAliases = {
      love = "echo 'Edu: Te amo Uri <3'";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  # programs.cnping.enable = true;

  services.flatpak.enable = true;
  cookiecutie.git.enable = true;
  uri.steam.enable = true;
  uri.vscode.enable = true;
  uri.jetbrains.enable = true;
  uri.rust.enable = true;
  uri.java.enable = true;
  uri.javascript.enable = true;
  uri.obs.enable = true;
  # 指
  uri.yubi.enable = true;
  programs.adb.enable = true;
  programs.nix-ld.enable = true;
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # Apple
  services.usbmuxd.enable = true;

  # programs.git.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    radeontop
    libreoffice-qt
    (firefox-wayland.override {
      nativeMessagingHosts = [
        inputs.pipewire-screenaudio.packages.${pkgs.system}.default
        pkgs.kdePackages.plasma-browser-integration
        pkgs.fx-cast-bridge
      ];
    })
    chromium
    vim-full # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tree
    neofetch
    killall
    htop
    file
    inetutils
    binutils-unwrapped
    psmisc
    pciutils
    usbutils
    dig
    asciinema
    ripgrep # a better grep
    unzip
    ncdu_1 # _2 only supports modern microarchs
    fd # a better find
    hyperfine # a better time
    mtr # a better traceroute
    tmux # when you can't afford i3
    youtube-dl
    yt-dlp # do some pretendin' and fetch videos
    jq # like 'node -e' but nicer
    btop # htop on steroids
    expect # color capture, galore
    caddy # convenient bloated web server
    parallel # --citation
    nix-tree # nix what-depends why-depends who-am-i
    libayatana-appindicator
    wl-clipboard
    wev
    wl-mirror
    wl-color-picker
    # gnomeExtensions.appindicator
    # gnome.gnome-tweaks
    nvtopPackages.amd
    remmina
    vulkan-headers
    vulkan-loader
    vulkan-tools
    sidequest
    distrobox
    pavucontrol
    docker-compose
    distrobox
    epiphany
    kdePackages.kdeconnect-kde

    # wine-staging (version with experimental features)
    # wineWowPackages.staging
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
    dxvk
    protontricks

    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
      ];
    })
    heroic
    pkgsi686Linux.gperftools

    # Apple
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'

    rocmPackages.rocminfo
    rocmPackages.rocm-smi
  ];

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.upower.enable = true;

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      # gtkUsePortal = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fwupd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # this file is not created and it's required for networkmanager ipsec
  environment.etc = {
    "ipsec.secrets".text = ''
      include ipsec.d/ipsec.nm-l2tp.secrets
    '';
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
