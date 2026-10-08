{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.cookiecutie.sound;
in
with lib;
{
  options.cookiecutie.sound = {
    enable = mkEnableOption "Enable the ALSA sound system";
    pro = mkEnableOption "Enable additional Pro Audio configuration";
    pulse = {
      enable = mkEnableOption "Enable the PulseAudio sound system";
      lowLatency = mkEnableOption "Enable the low-latency PulseAudio configuration";
    };
    pipewire = {
      enable = mkEnableOption "Enable the PipeWire sound system";
      quantum = mkOption rec {
        type = types.int;
        default = 64;
        description = "Magical PipeWire value to magically perform things faster";
        example = default;
      };
      rate = mkOption rec {
        type = types.int;
        default = 48000;
        description = "The sample rate";
        example = default;
      };
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.pulse.enable && cfg.pipewire.enable);
          message = "PulseAudio conflicts with PipeWire";
        }
      ];
    }
    ### ALSA
    (mkIf cfg.enable { sound.enable = true; })
    ### Musnix
    (mkIf cfg.pro {
      musnix.enable = true;
      environment.systemPackages = with pkgs; [
        zrythm
        vital
      ];
    })
    ### PulseAudio
    (mkIf cfg.pulse.enable {
      security.rtkit.enable = true;
      hardware.pulseaudio = mkMerge [
        (mkIf cfg.pulse.lowLatency {
          configFile = ./default.pa;
          daemon.config = {
            "high-priority" = "yes";
            "nice-level" = "-15";
            "realtime-scheduling" = "yes";
            "realtime-priority" = "50";
            "resample-method" = "speex-float-0";
            "default-fragments" = "2";
            "default-fragment-size-msec" = "4";

            "default-sample-format" = "s32le";
            "default-sample-rate" = toString rate;
            "alternate-sample-rate" = toString rate;
            "default-sample-channels" = "2";
          };
        })
        { enable = true; }
      ];
    })
    ### PipeWire
    (mkIf cfg.pipewire.enable (
      let
        inherit (cfg.pipewire) quantum rate;
      in
      {
        environment.systemPackages = with pkgs; [
          crosspipe
          pulseaudio
        ];

        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          audio.enable = true;
          pulse.enable = true;
          jack.enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };

          lowLatency = {
            # enable this module
            enable = true;
            # defaults (no need to be set unless modified)
            quantum = quantum;
            rate = rate;
          };
          package = pkgs.pipewire.overrideAttrs (old: {
            version = "1.7.0+90b719ac";
            src = pkgs.fetchFromGitLab {
              domain = "gitlab.freedesktop.org";
              owner = "lorbus";
              repo = "pipewire";
              rev = "90b719acbeb2bc5d3181d40c630427b60e694d98";
              hash = "sha256-CXeqDdU3jBsNy6wogn2lJJ1+Ks1l8TQX12Y/IA6uHkM=";
            };
            patches = lib.lists.take 2 old.patches;
            buildInputs = old.buildInputs ++ [
              pkgs.libplist
              (pkgs.callPackage ../../packages/lhdcv5.nix {})
            ];
          });
          # wireplumber 0.5.15 is broken for me
          # wireplumber.package = pkgs.wireplumber.overrideAttrs (_: rec {
          #   version = "0.5.14";
          #   src = pkgs.fetchFromGitLab {
          #     domain = "gitlab.freedesktop.org";
          #     owner = "pipewire";
          #     repo = "wireplumber";
          #     tag = version;
          #     hash = "sha256-Ap7vrkSxVQFzAJoBN8wWer4gOFc8iknN1A9KyRfdImc=";
          #   };
          # });
          # used to have lots of config from sctanf, last in a5626226295a08b9c648f8f75594a65a57095f70
          configPackages = [
            (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/50-airplay.conf" ''
              context.modules = [
                {
                  name = libpipewire-module-raop-discover
                  args = {
                    raop.latency.ms = 40
                  }
                }
              ]
            '')
          ];
        };
      }
    ))
  ];
}
