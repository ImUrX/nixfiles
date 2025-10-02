{ ... }:
{
  users.users.uri = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "wheel"
      "input"
      "adbusers"
      "plugdev"
      "docker"
      "dialout"
      "audio"
      "scanner"
      "lp"
      "wireshark"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    initialPassword = "eevee123";
  };
  users.groups.plugdev = { };

  home-manager.users.uri =
    {
      config,
      lib,
      headless,
      ...
    }:
    {
      imports = [
        ../../modules/git.nix
        ../../modules/js.nix
        ../../modules/java.nix
        ../../modules/rust.nix
      ] ++ lib.optional (!headless) ./gui.nix;

      home.stateVersion = "23.05";

      systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };

      programs.direnv.enable = true;
      programs.direnv.enableBashIntegration = true;
      programs.bash.enable = true;
      programs.distrobox.enable = true;

      cookiecutie.git.enable = true;
      uri.rust.enable = true;
      uri.java.enable = true;
      uri.javascript.enable = true;

      home.shellAliases = {
        love = "echo 'Edu: Te amo Uri <3'";
      };
      programs.bash.initExtra = ''
        nixos-remote () {
          if [ $# -eq 0 ]; then
            echo "No arguments supplied"
          elif [ $# -eq 2 ]; then
            nixos-rebuild switch --flake ".#$1" --build-host $2 --target-host $2 --sudo --ask-sudo-password --use-substitutes
          else
            nixos-rebuild $3 --flake ".#$1" --build-host $2 --target-host $2 --sudo --ask-sudo-password --use-substitutes
          fi
        }
      '';

      # home.activation = {
      #   import-ssh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #     PATH="${pkgs.ssh-import-id}/bin:${pkgs.openssh}/bin:$PATH" run ssh-import-id-gh imurx
      #   '';
      # };
    };
}
