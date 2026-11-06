# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  ...
}:
{
  imports = [
    ./headless.nix
    ./modules/kde
    ./modules/sound
    ./modules/fonts.nix
    ./modules/steam.nix
    ./modules/yubikey.nix
    ./modules/nix-ld.nix
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
  networking.networkmanager.wifi.backend = "iwd";

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

  # Enable sound.
  cookiecutie.sound.pipewire.enable = true;

  # Logitech
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # RGB Addressing
  services.hardware.openrgb = {
    enable = true;
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
  };

  uri.kde.enable = true;
  uri.steam.enable = true;
  # 指
  uri.yubi.enable = true;

  # Optimization
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
  services.bpftune.enable = true;
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" ];
  };
  programs.corectrl.enable = true;

  cookie.fonts.enable = true;
  # programs.cdemu.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      # Network
      (firefox.override {
        nativeMessagingHosts = [
          # inputs.pipewire-screenaudio.packages.${pkgs.system}.default
          pkgs.kdePackages.plasma-browser-integration
          # pkgs.fx-cast-bridge
        ];
      })
      qbittorrent
      chromium
      epiphany
      wireshark

      # Documents
      libreoffice-qt

      # Art
      gimp3

      # Media
      feishin
      mpv
      pavucontrol
      psst

      # Games
      prismlauncher
      gamescope # gamescope-wsi will let me use HDR, but it breaks steam overlay apparently

      # Utilities
      libayatana-appindicator
      xeyes
      mission-center
      kitty
      lm_sensors
      ## Logitech
      piper
      openlogi
      ## Wayland
      wl-clipboard
      wev
      wl-mirror
      wl-color-picker

      # Development
      remmina
      vulkan-headers
      vulkan-loader
      vulkan-tools
      nixd # LSP for Nix
      nixfmt

      # Apple
      libimobiledevice
      ifuse # optional, to mount using 'ifuse'
    ]
    ++ (
      if pkgs.system == "x86_64-linux" then
        with pkgs;
        [
          # Social
          (discord.override {
            enableAutoscroll = true;
            # withOpenASAR = true;
            withEquicord = true;
            equicord = pkgs.equicord.overrideAttrs (old: rec {
              version = "2026-11-04";
              src = pkgs.fetchFromGitHub {
                owner = "Equicord";
                repo = "Equicord";
                tag = version;
                hash = "sha256-BfthELkW+p0sF8A0zywJVT2Y6XBSyS0PJK5HjOLSr0c=";
              };

              pnpmDeps = fetchPnpmDeps {
                inherit (old) pname;
                version = version;
                src = src;
                pnpm = pnpm_12;
                fetcherVersion = 5;
                hash = "sha256-l19oMNqFMva7m8DAe9x+IJLM2O87GVwZayyE1ci7HvM=";
              };
            });
          })

          spotify
          plexamp
          plex-desktop
        ]
      else
        with pkgs;
        [
          equibop
        ]
    );
  security.wrappers.nethogs = {
    owner = "root";
    group = "root";
    source = "${pkgs.nethogs}/bin/nethogs";
    capabilities = "cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace+pe";
  };

  # Apple
  services.usbmuxd.enable = true;

  services.flatpak.enable = true;
  services.ratbagd.enable = true;
  programs.localsend.enable = true;
  programs.wireshark.enable = true;

  # this file is not created and it's required for networkmanager ipsec
  environment.etc = {
    "ipsec.secrets".text = ''
      include ipsec.d/ipsec.nm-l2tp.secrets
    '';
    "distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro"
    '';
  };

  environment.sessionVariables = {
    TERMINAL = "kitty";
  };
}
