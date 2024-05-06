{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cookiecutie.git;
in
  with lib; {
    options.cookiecutie.git = {
      enable = mkEnableOption "Enables and configures git";
      name = mkOption rec {
        type = types.str;
        default = "Uriel";
        description = "Username to use with git";
        example = default;
      };
      email = mkOption rec {
        type = types.str;
        default = "imurx@proton.me";
        description = "Email to use with git";
        example = default;
      };
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        git-interactive-rebase-tool
      ];

      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        userEmail = cfg.email;
        userName = cfg.name;

        lfs.enable = true;
        difftastic.enable = true;

        aliases = {};

        extraConfig = {
          # Cooler interactive rebase
          sequence.editor = "interactive-rebase-tool";
          # https://git-scm.com/book/en/v2/Git-Tools-Rerere
          rerere.enabled = true;

          submodule = {
            recurse = true;
          };
          push = {
            autoSetupRemote = true;
          };
          pull = {
            rebase = true;
            # ff = "only";
          };
          commit = {
            gpgSign = true;
          };
          http = {
            postBuffer = 2097152000;
          };
          https = {
            postBuffer = 2097152000;
          };
          init.defaultBranch = "main";
          # Rewrite unencrypted git://github.com URLs to the encrypted version which isn't deprecated
          ${''url "git@github.com:"''} = {insteadOf = "git://github.com/";};

          maintenance = {
            repo = "";
          };
        };
      };

      # https://github.com/nix-community/home-manager/issues/2765
      systemd.user = {
        services = let
          serviceCommand = {
            name,
            command,
          }: {
            Unit = {
              Wants = "${name}.timer";
            };

            Service = {
              Type = "oneshot";
              ExecStart = command;
            };

            Install = {
              WantedBy = ["multi-user.target"];
            };
          };

          serviceGit = {time}:
            serviceCommand {
              name = "git-${time}";
              command = let
                git = config.programs.git.package;
              in ("${git}/libexec/git-core/git --exec-path=${git}/libexec/git-core/ for-each-repo "
                + "--config=maintenance.repo maintenance run --schedule=${time}");
            };
        in {
          git-hourly = serviceGit {time = "hourly";};
          git-daily = serviceGit {time = "daily";};
          git-weekly = serviceGit {time = "weekly";};
        };

        timers = let
          timer = {
            name,
            onCalendar,
          }: {
            Unit = {
              Requires = "${name}.service";
            };

            Timer = {
              OnCalendar = onCalendar;
              AccuracySec = "12h";
              Persistent = true;
            };

            Install = {
              WantedBy = ["timers.target"];
            };
          };
        in {
          git-hourly = timer {
            name = "git-hourly";
            onCalendar = "hourly";
          };

          git-daily = timer {
            name = "git-daily";
            onCalendar = "hourly";
          };

          git-weekly = timer {
            name = "git-weekly";
            onCalendar = "weekly";
          };
        };
      };
    };
  }
