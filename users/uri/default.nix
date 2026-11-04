{
  pkgs,
  inputs,
  lib,
  ...
}:
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
        inputs.nixvim.homeModules.nixvim
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
      programs.bat.enable = true;
      programs.ripgrep-all = {
        enable = true;
      };
      programs.eza = {
        enable = true;
        git = true;
        icons = "auto";
        colors = "auto";
      };
      programs.tealdeer = {
        enable = true;
        enableAutoUpdates = true;
      };
      programs.nixvim = {
        enable = true;
        imports = [ (lib.modules.importApply ../../modules/nixvim { inherit inputs; }) ];
      };

      cookiecutie.git.enable = true;
      uri.rust.enable = true;
      uri.java.enable = true;
      uri.javascript.enable = true;

      home.shellAliases = {
        love = "echo 'Edu: Te amo Uri <3'";
        ls = "eza";
      };
      programs.bash.initExtra =
        let
          steam = "${config.xdg.dataHome}/Steam";
        in
        ''
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
            target_file=$( [ "$3" ] && echo "$3" || echo "''${file}-''${target_size_mb}mb.webm" )
            target_size=$(( $target_size_mb * 1000 * 1000 * 8 )) # target size in bits
            length=`${pkgs.ffmpeg}/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file"`
            length_round_up=$(( ''${length%.*} + 1 ))
            total_bitrate=$(( $target_size / $length_round_up ))
            video_bitrate=$total_bitrate
            ${pkgs.libva-utils}/bin/vainfo | ${pkgs.ripgrep}/bin/rg "AV1Profile.+VAEntrypointEncSlice" && \
              ${pkgs.ffmpeg}/bin/ffmpeg -init_hw_device vaapi=foo:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device foo -i "$file" \
                -filter_hw_device foo -vf "deinterlace_vaapi=rate=field:auto=1,scale_vaapi=w='min(2560,iw)':h='min(1440,ih)',format=nv12|vaapi,hwupload" \
                -c:v av1_vaapi -b:v $video_bitrate -maxrate:v $video_bitrate -bufsize:v $(( $target_size / 20 )) $target_file || \
              ${pkgs.ffmpeg}/bin/ffmpeg -i "$file" -c:v libsvtav1 -crf 35 -svtav1-params rc=2:pred-struct=1 -vf "scale='min(2560,iw)':'min(1440,ih)'" \
                -b:v $video_bitrate -maxrate:v $video_bitrate -bufsize:v $(( $target_size / 20 )) $target_file
          }
        ''
        + lib.optionalString (!headless) ''
          steam_clip () {
            declare -A maps=( ["cs2"]="730" ["tf2"]="440" ["l4d2"]="550" )
            appid=
            if [[ "$2" ]]; then
              if [[ "''${maps["$2"]}" ]]; then
                appid="clip_''${maps["$2"]}"
              else
                appid=$( ${pkgs.gnugrep}/bin/grep -li "\"$2\"" '${steam}/steamapps/appmanifest_*.acf' || return )
                appid="clip_''${appid:${builtins.toString (builtins.stringLength "${steam}/steamapps/appmanifest_")}:-4}"
              fi
              
              echo "$2 is $appid"
            fi
            most_recent_user=$( command ls -td '${steam}'/userdata/*/ | head -1 || return) 
            most_recent_clip=$( command ls -td "$most_recent_user"gamerecordings/clips/"$appid"*/ | head -1 || return)
            most_recent_clip=$( command ls -td "$most_recent_clip"video/*/ | head -1 || return )

            ${pkgs.xmlstarlet}/bin/xmlstarlet ed -d '//_:Period/@start' "$most_recent_clip"session.mpd > "$most_recent_clip"fix.mpd
            trap '{ rm -f -- "$most_recent_clip"fix.mpd; }' RETURN
            if [[ "$1" ]]; then
              ffmpeg_resize "$most_recent_clip"fix.mpd $1 "clip-$( date +%Y%m%d-%H%M%S ).mp4"
            else
              ${pkgs.ffmpeg}/bin/ffmpeg -i "$most_recent_clip"fix.mpd -codec copy "clip-$( date +%Y%m%d-%H%M%S ).mp4"
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
