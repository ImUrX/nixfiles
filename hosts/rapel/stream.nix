{ config, ... }:
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
}
