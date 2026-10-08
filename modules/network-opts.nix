{
  config,
  lib,
  ...
}:
let
  cfg = config.uri.net-opts;
in
with lib;
{
  options.uri.net-opts = {
    enable = mkEnableOption "Enables and configures network optimizations";
  };

  config = mkIf cfg.enable {
    # Based on https://wiki.archlinux.org/title/Sysctl#Improving_performance
    boot.kernel.sysctl = {
      "net.core.somaxconn" = 8192;

      "net.core.rmem_default" = 1048576;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_default" = 1048576;
      "net.core.wmem_max" = 16777216;
      "net.core.optmem_max" = 65536;

      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;

      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_sack" = 1;

      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    boot.kernelModules = [
      "tcp_bbr"
    ];
  };
}
