{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./modules/nix.nix
    ./modules/network-opts.nix
    ./modules/yazi
  ];
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services.resolved = {
    enable = true;
    # settings.Resolve = {
    #   DNSSEC = "true";
    #   Domains = [ "~." ];
    #   DNSOverTLS = "true";
    #   FallbackDNS = [
    #     "1.1.1.1"
    #     "1.0.0.1"
    #   ];
    # };
  };

  # System services
  security.polkit.enable = true;
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Ambient sensor
  hardware.sensor.iio.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Files
    vim-full
    file
    binutils
    tree
    ripgrep # a better grep
    ncdu_1 # _2 only supports modern microarchs
    fd # a better find
    bat # a cat alternative

    # Compress
    zip
    unzip
    unrar

    # Network
    wget
    inetutils
    dig
    mtr # a better traceroute
    caddy # convenient bloated web server
    docker-compose
    nethogs

    # Nix
    appimage-run
    nix-tree # nix what-depends why-depends who-am-i
    inputs.agenix.packages.${pkgs.system}.default
    vulnix

    # Cool
    hyfetch
    fastfetch
    asciinema
    yt-dlp # do some pretendin' and fetch videos
    jq # like 'node -e' but nicer

    # Processes
    htop
    killall
    pciutils

    # /sys/ inspects
    psmisc
    usbutils
    hyperfine # a better time

    # TTY stuff
    tmux # when you can't afford i3
    expect # color capture, galore
    parallel # --citation
    kitty # for TERMINFO
  ];

  # beauty looking traceroute
  programs.mtr.enable = true;
  # Cool looking shell
  programs.starship = {
    enable = true;
    presets = [ "pastel-powerline" ];
  };
  # a nice file commander
  uri.yazi.enable = true;
  # a smarter cd command
  programs.zoxide.enable = true;
  # The unsung hero
  programs.screen.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Hardware firmware updates
  services.fwupd.enable = true;

  # udev but for energy
  services.upower.enable = true;
  # services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7690",  MODE="0666", GROUP="dialout", TAG+="uaccess", TAG+="udev-acl"
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  '';

  # ssd optimization
  services.fstrim.enable = true;
  # net optimization
  uri.net-opts.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  environment.shellAliases = {
    "nix-switch" = "sudo nixos-rebuild --flake .?submodules=1 switch";
    "neofetch" = "hyfetch";
    "find" = "fd";
    "traceroute" = "mtr";
    "ll" = "ls -l";
    "cd" = "z";
    "cat" = "bat";
  };
  environment.sessionVariables = {
    _ZO_DOCTOR = "0";
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
