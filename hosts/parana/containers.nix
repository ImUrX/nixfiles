{
  config,
  pkgs,
  lib,
  ...
}: {
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

  services.gotenberg = {
    enable = true;
    package = pkgs.gotenberg.overrideAttrs (old: rec {
      version = "8.20.1";

      src = pkgs.fetchFromGitHub {
        owner = "gotenberg";
        repo = "gotenberg";
        tag = "v${version}";
        hash = "sha256-3+6bdO6rFSyRtRQjXBPefwjuX0AMuGzHNAQas7HNNRE=";
      };

      vendorHash = "sha256-qZ4cgVZAmjIwXhtQ7DlAZAZxyXP89ZWafsSUPQE0dxE=";

      postPatch = ''
        find ./pkg -name '*_test.go' -exec sed -i -e 's#/tests#${src}#g' {} \;
      '';
    });
    chromium.disableJavascript = true;
    extraArgs = ["--chromium-allow-list=file:///tmp/.*"];
  };

  uri.paperless.enable = true;
}
