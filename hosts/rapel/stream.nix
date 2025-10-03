{ config, pkgs, ... }:
{
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  services.cloudflared = {
    enable = true;
    tunnels = {
      "8f735f1f-39b5-4402-bc8f-b5e7dd254da5" = {
        credentialsFile = "${config.age.secrets.cloudflared.path}";
        default = "http_status:404";
      };
    };
  };

  nixarr.enable = true;
  nixarr.plex.enable = true;

  systemd.timers.update-mirror = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Persistent = true;
      OnCalendar = "*-*-* 00:00:00";
    };
  };
  systemd.services.update-mirror = {
    serviceConfig = {
      Type = "oneshot";
    };
    script = "${pkgs.rsync}/bin/rsync -za --progress rsync://parana.ruffe-dojo.ts.net/movies/ /data/media/library/movies";
  };
}
