# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./headless.nix
    ./modules/kde.nix
    ./modules/sound
    ./fonts.nix
    ./modules/steam.nix
    ./modules/yubikey.nix
  ];
  # virtualisation.waydroid.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.sane.enable = true;
  # HP giving 403
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  services.printing.drivers = with pkgs; [
    postscript-lexmark
    epson-escpr
  ];

  services.udev.packages = [
    pkgs.platformio-core
    pkgs.openocd
  ];

  programs.wireshark.enable = true;

  # Enable sound.
  #sound.enable = true;
  #services.pipewire.enable = true;
  # hardware.pulseaudio.enable = lib.mkForce false;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  cookiecutie.sound.pipewire.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # RGB Addressing
  # services.hardware.openrgb = {
  #   enable = true;
  #   package = pkgs.openrgb.overrideAttrs (old: {
  #     version = "1.0-experimental";
  #     src = pkgs.fetchFromGitLab {
  #       owner = "CalcProgrammer1";
  #       repo = "OpenRGB";
  #       rev = "041c7600b7995173aecbbd9c8e5bfece192030f2";
  #       hash = "sha256-Vif3b1xRj99uwiF9GoPDZAnX3V/UlEFXSreWhAmqraM=";
  #     };

  #     postPatch = ''
  #       patchShebangs scripts/build-udev-rules.sh
  #       substituteInPlace scripts/build-udev-rules.sh \
  #         --replace "/usr/bin/env chmod" "${pkgs.coreutils}/bin/chmod"
  #     '';
  #   });
  # };

  uri.kde.enable = true;
  uri.steam.enable = true;
  # 指
  uri.yubi.enable = true;
  programs.adb.enable = true;
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
  programs.corectrl.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    gimp3
    prismlauncher
    qbittorrent
    spotify
    chromium
    libayatana-appindicator
    wl-clipboard
    wev
    wl-mirror
    wl-color-picker
    gamescope # gamescope-wsi will let me use HDR, but it breaks steam overlay apparently
    # gnomeExtensions.appindicator
    # gnome.gnome-tweaks
    # nur.repos.ataraxiasjel.waydroid-script
    remmina
    vulkan-headers
    vulkan-loader
    vulkan-tools
    pavucontrol
    epiphany
    lm_sensors
    # LSP for Nix
    nil
    nixfmt-rfc-style
    wireshark
    # Disabled for now https://github.com/NixOS/nixpkgs/issues/404663
    # (ventoy-full.override {
    #   defaultGuiType = "qt5";
    # })

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

  # Apple
  services.usbmuxd.enable = true;

  services.flatpak.enable = true;
  services.ratbagd.enable = true;
  services.lact.enable = true;

  # this file is not created and it's required for networkmanager ipsec
  environment.etc = {
    "ipsec.secrets".text = ''
      include ipsec.d/ipsec.nm-l2tp.secrets
    '';
    "distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro"
    '';
  };
}
