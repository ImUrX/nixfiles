{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    ghostscript
  ];
  extraLuaPackages = ps: [
    ps.magick
  ];
  dependencies.curl.enable = true;
  dependencies.imagemagick.enable = true;
  plugins.image = {
    enable = true;
    package = pkgs.vimPlugins.image-nvim.overrideAttrs (_: {
      src = pkgs.fetchFromGitHub {
        owner = "msva";
        repo = "image.nvim";
        rev = "cf7a0f3c2af3a9a8c2ac5d16022b41a40d5e7b89";
        hash = "sha256-8bRGmGBULNkkc85rYUTn0KB+xjL5GLr/kz+CKUzF4So=";
      };
    });
    settings = {
      processor = "magick_rock";
    };
  };
  plugins.img-clip = {
    enable = true;
    settings = {
      norg = {
        url_encode_path = true;
        template = ".image $FILE_PATH\n$CURSOR";
        download_images = false;
      };
    };
  };
}
