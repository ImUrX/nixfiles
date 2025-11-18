# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}: {
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
  hardware.sane.extraBackends = [pkgs.hplipWithPlugin];
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
  cookie.fonts.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libreoffice-qt
    (firefox.override {
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

    plexamp
    plex-desktop
  ];

  # Apple
  services.usbmuxd.enable = true;

  services.flatpak.enable = true;
  services.ratbagd.enable = true;
  services.lact.enable = true;

  # programs.nix-ld.libraries = with pkgs; [
  #   # List by default
  #     zlib
  #     zstd
  #     stdenv.cc.cc
  #     curl
  #     openssl
  #     attr
  #     libssh
  #     bzip2
  #     libxml2
  #     acl
  #     libsodium
  #     util-linux
  #     xz
  #     systemd
      
  #     # My own additions
  #     xorg.libXcomposite
  #     xorg.libXtst
  #     xorg.libXrandr
  #     xorg.libXext
  #     xorg.libX11
  #     xorg.libXfixes
  #     libGL
  #     libva
  #     pipewire
  #     xorg.libxcb
  #     xorg.libXdamage
  #     xorg.libxshmfence
  #     xorg.libXxf86vm
  #     libelf

  #     # Required
  #     glib
  #     gtk2

  #     # Inspired by steam
  #     # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
  #     networkmanager      
  #     vulkan-loader
  #     libgbm
  #     libdrm
  #     libxcrypt
  #     coreutils
  #     pciutils
  #     zenity
  #     # glibc_multi.bin # Seems to cause issue in ARM
      
  #     # # Without these it silently fails
  #     xorg.libXinerama
  #     xorg.libXcursor
  #     xorg.libXrender
  #     xorg.libXScrnSaver
  #     xorg.libXi
  #     xorg.libSM
  #     xorg.libICE
  #     gnome2.GConf
  #     nspr
  #     nss
  #     cups
  #     libcap
  #     SDL2
  #     libusb1
  #     dbus-glib
  #     ffmpeg
  #     # Only libraries are needed from those two
  #     libudev0-shim
      
  #     # needed to run unity
  #     gtk3
  #     icu
  #     libnotify
  #     gsettings-desktop-schemas
  #     # https://github.com/NixOS/nixpkgs/issues/72282
  #     # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
  #     # log in /home/leo/.config/unity3d/Editor.log
  #     # it will segfault when opening files if you don’t do:
  #     # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
  #     # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed
      
  #     # Verified games requirements
  #     xorg.libXt
  #     xorg.libXmu
  #     libogg
  #     libvorbis
  #     SDL
  #     SDL2_image
  #     glew110
  #     libidn
  #     tbb
      
  #     # Other things from runtime
  #     flac
  #     freeglut
  #     libjpeg
  #     libpng
  #     libpng12
  #     libsamplerate
  #     libmikmod
  #     libtheora
  #     libtiff
  #     pixman
  #     speex
  #     SDL_image
  #     SDL_ttf
  #     SDL_mixer
  #     SDL2_ttf
  #     SDL2_mixer
  #     libappindicator-gtk2
  #     libdbusmenu-gtk2
  #     libindicator-gtk2
  #     libcaca
  #     libcanberra
  #     libgcrypt
  #     libvpx
  #     librsvg
  #     xorg.libXft
  #     libvdpau
  #     # ...
  #     # Some more libraries that I needed to run programs
  #     pango
  #     cairo
  #     atk
  #     gdk-pixbuf
  #     fontconfig
  #     freetype
  #     dbus
  #     alsa-lib
  #     expat
  #     # for blender
  #     libxkbcommon

  #     libxcrypt-legacy # For natron
  #     libGLU # For natron

  #     # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
  #     fuse
  #     e2fsprogs
  # ]; 

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
