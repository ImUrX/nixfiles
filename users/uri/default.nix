{ pkgs, ... }:
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
      "cdrom"
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
      ]
      ++ lib.optional (!headless) ./gui.nix;

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
            nixos-rebuild switch --flake ".?submodules=1#$1" --build-host $2 --target-host $2 --sudo --ask-sudo-password --use-substitutes
          else
            nixos-rebuild $3 --flake ".?submodules=1#$1" --build-host $2 --target-host $2 --sudo --ask-sudo-password --use-substitutes
          fi
        }

        ffmpeg_resize () {
          file=$1
          target_size_mb=$2  # target size in MB
          target_size=$(( $target_size_mb * 1000 * 1000 * 8 )) # target size in bits
          length=`${pkgs.ffmpeg}/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file"`
          length_round_up=$(( ''${length%.*} + 1 ))
          total_bitrate=$(( $target_size / $length_round_up ))
          video_bitrate=$total_bitrate
          ${pkgs.libva-utils}/bin/vainfo | ${pkgs.ripgrep}/bin/rg "AV1Profile.+VAEntrypointEncSlice" && \
            ${pkgs.ffmpeg}/bin/ffmpeg -init_hw_device vaapi=foo:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device foo -i "$file" \
              -filter_hw_device foo -vf 'format=nv12|vaapi,hwupload' -c:v av1_vaapi -b:v $video_bitrate -maxrate:v $video_bitrate \
              -bufsize:v $(( $target_size / 20 )) "''${file}-''${target_size_mb}mb.webm" || \
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$file" -c:v libsvtav1 -crf 35 -svtav1-params rc=2:pred-struct=1 -b:v $video_bitrate -maxrate:v $video_bitrate \
              -bufsize:v $(( $target_size / 20 )) "''${file}-''${target_size_mb}mb.webm"
        }
      '';
      # home.activation = {
      #   import-ssh = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #     PATH="${pkgs.ssh-import-id}/bin:${pkgs.openssh}/bin:$PATH" run ssh-import-id-gh imurx
      #   '';
      # };
    };
}
