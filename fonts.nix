{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cookie.fonts;
in
with lib;
{
  options.cookie.fonts = {
    enable = mkEnableOption "Enables a collection of fonts";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
        waylandFrontend = true;
      };
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        hack-font
        ubuntu-classic
        corefonts
        # google-fonts # this kills doom emacs performance for some reason. Do not use.
        proggyfonts
        cantarell-fonts
        material-design-icons
        weather-icons
        font-awesome_5 # 6 breaks polybar
        emacs-all-the-icons-fonts
        source-sans-pro
        jetbrains-mono
        inter
        ipaexfont
        mplus-outline-fonts.githubRelease
        twemoji-color-font
      ];
      fontDir.enable = true;

      fontconfig = {
        defaultFonts = {
          monospace = [ "JetBrains Mono" "Mplus Code 60" ];
          sansSerif = [ "Inter" "IPAexGothic" ];
          serif = [ "Noto Serif" "IPAexMincho" ];
          emoji = [ "Twitter Color Emoji" ];
        };
      };
    };
  };
}
