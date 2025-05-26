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

  programs.dconf.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  virtualisation.docker.enable = true;

  security.polkit.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };
  # programs.cnping.enable = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  environment.systemPackages = with pkgs; [
    appimage-run
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
    unrar
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
    inputs.rfm.packages.${pkgs.system}.default # a nice file commander with vim controls
    docker-compose
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # a smarter cd command
  programs.zoxide.enable = true;
  programs.screen.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fwupd.enable = true;

  services.upower.enable = true;
  # services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7690",  MODE="0666", GROUP="dialout", TAG+="uaccess", TAG+="udev-acl"
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  '';

  # ssd optimization
  services.fstrim.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  environment.shellAliases = {
    "nix-switch" = "sudo nixos-rebuild --flake . switch";
    "neofetch" = "hyfetch";
    "find" = "fd";
    "traceroute" = "mtr";
    "grep" = "rg";
    "ll" = "ls -l";
    "ls" = "eza --smart-group --git";
    "cd" = "z";
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
