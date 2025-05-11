{
  config,
  pkgs,
  lib,
  ...
}:
rec {
  imports = [
    ./arrs.nix
    ../../modules/wg-pnp.nix
    ../../modules/soulseek.nix
  ];
  nixarr.enable = true;
  users.users.streamer.extraGroups = [ "media" ];

  # VPN
  nixarr.vpn = {
    enable = true;
    wgConf = config.age.secrets.vpn-ar.path;
  };
  vpnNamespaces.wg.accessibleFrom = lib.mkForce [
    "192.168.0.0/16"
    "100.100.0.0/16"
    "127.0.0.1"
  ];

  # Transmission
  nixarr.transmission = {
    enable = true;
    flood.enable = true;
    messageLevel = "info";
    vpn.enable = true;

    extraSettings = {
      port-forwarding-enabled = false;
      rpc-host-whitelist = "*";
    };
  };

  uri.wg-pnp.transmission = {
    vpnNamespace = "wg";
    runScript = ''
      if [ "$protocol" = tcp ]
      then
        echo "Telling transmission to listen on peer port $new_port."
        ${pkgs.transmission}/bin/transmission-remote 192.168.15.1 --port "$new_port"
      fi
    '';
  };

  # Sabnzbd
  nixarr.sabnzbd = {
    enable = true;
    whitelistHostnames = [ "nz.2dgirls.date" ];
  };

  # Soulseek
  uri.slsk = {
    enable = true;
    downloads = "/data/media/soulseek/downloads";
    incomplete = "/data/media/soulseek/incomplete";
  };

  virtualisation.oci-containers.containers.soularr = {
    autoStart = true;
    image = "mrusse08/soularr:latest";
    extraOptions = [ "--hostuser=streamer" ];
    hostname = "soularr";
    environment = {
      TZ = "ETC/UTC";
      SCRIPT_INTERVAL = "300";
    };
    volumes = [
      "${uri.slsk.downloads}:/downloads"
      "${dirOf config.age.secrets.soularr.path}:/data"
    ];
  };

  # Plex
  nixarr.plex.enable = true;
}
