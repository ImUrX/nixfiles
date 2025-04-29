{
  pkgs,
  lib,
  ...
}: {
  imports = [];

  networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = ["ve-*"];
    externalInterface = "ens3";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  # If you are using Network Manager, you need to explicitly prevent it from managing container interfaces:
  networking.networkmanager.unmanaged = ["interface-name:ve-*"];
}
