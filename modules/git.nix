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
        default = "urielfontan2002@gmail.com";
        description = "Email to use with git";
        example = default;
      };
    };

    config = mkIf cfg.enable {
      home-manager.users.uri = {...}: {
        programs.git = {
          enable = true;
          package = pkgs.gitFull;
          lfs.enable = true;
          userEmail = cfg.email;
          userName = cfg.name;
          extraConfig = {
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
            init.defaultBranch = "main";
            # Rewrite unencrypted git://github.com URLs to the encrypted version which isn't deprecated
            ${''url "git@github.com:"''} = {insteadOf = "git://github.com/";};
          };
        };
      };
    };
  }
