# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
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
    ./modules/steam.nix
    ./modules/yubikey.nix
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    sandbox = true;
  };
  nix.optimise.automatic = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  virtualisation.waydroid.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  environment.shellAliases = {
    "nix-switch" = "sudo nixos-rebuild --flake . switch";
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
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  programs.dconf.enable = true;

  # ssd optimization
  services.fstrim.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [pkgs.hplipWithPlugin];
  services.printing.drivers = with pkgs; [
    postscript-lexmark
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Enable sound.
  #sound.enable = true;
  #services.pipewire.enable = true;
  # hardware.pulseaudio.enable = lib.mkForce false;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.ratbagd.enable = true;
  cookiecutie.sound.pipewire.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security.polkit.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };
  # programs.cnping.enable = true;

  services.flatpak.enable = true;
  uri.steam.enable = true;
  # 指
  uri.yubi.enable = true;
  programs.adb.enable = true;
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        amd_performance_level = "high";
      };
    };
  };

  # Apple
  services.usbmuxd.enable = true;

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
    piper
    (vesktop.override {
      withMiddleClickScroll = true;
    })
    mpv
    gimp
    prismlauncher
    qbittorrent
    appimage-run
    spotify
    chromium
    vim-full # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tree
    hyfetch
    fastfetch
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
    zip
    unzip
    ncdu_1 # _2 only supports modern microarchs
    fd # a better find
    hyperfine # a better time
    mtr # a better traceroute
    tmux # when you can't afford i3
    yt-dlp # do some pretendin' and fetch videos
    jq # like 'node -e' but nicer
    btop # htop on steroids
    expect # color capture, galore
    caddy # convenient bloated web server
    parallel # --citation
    nix-tree # nix what-depends why-depends who-am-i
    eza # ls but better
    libayatana-appindicator
    wl-clipboard
    wev
    wl-mirror
    wl-color-picker
    unrar
    gamescope #gamescope-wsi will let me use HDR, but it breaks steam overlay apparently
    # gnomeExtensions.appindicator
    # gnome.gnome-tweaks
    nvtopPackages.amd
    remmina
    vulkan-headers
    vulkan-loader
    vulkan-tools
    sidequest
    pavucontrol
    docker-compose
    epiphany
    kdePackages.kdeconnect-kde
    kdePackages.kleopatra
    lm_sensors
    # LSP for Nix
    nil
    skanpage
    wireshark

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

    # Apple
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
  ];

  # services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7690",  MODE="0666", GROUP="dialout", TAG+="uaccess", TAG+="udev-acl"
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  '';
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
    "distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro"
    '';
  };

  environment.shellAliases = {
    "neofetch" = "hyfetch";
    "find" = "fd";
    "traceroute" = "mtr";
    "grep" = "rg";
    "ll" = "eza -l --git";
    "ls" = "eza";
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
