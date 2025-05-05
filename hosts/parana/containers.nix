{config, ...}: {
  imports = [
    ../../modules/paperless.nix
  ];

  networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = ["ve-+"];
    externalInterface = "eno1";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "f63de86d-a4b9-43d3-b865-5a40f37ef85b" = {
        credentialsFile = "${config.age.secrets.cloudflared.path}";
        default = "http_status:404";
      };
    };
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  uri.paperless.enable = true;
}
