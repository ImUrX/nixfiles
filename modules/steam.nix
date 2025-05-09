{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.uri.steam;
  polkitEnabled = config.security.polkit.enable;
in
with lib;
{
  options.uri.steam = {
    enable = mkEnableOption "Enables and configures steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    security.polkit.extraConfig = mkIf polkitEnabled ''
      polkit.addRule(function(action, subject) {
        if (action.id === "org.freedesktop.NetworkManager.settings.modify.system") {
          var name = polkit.spawn(["cat", "/proc/" + subject.pid + "/comm"]);
          if (name.includes("steam")) {
            polkit.log("ignoring steam NM prompt");
            return polkit.Result.NO;
          }
        }
      });
    '';
  };
}
