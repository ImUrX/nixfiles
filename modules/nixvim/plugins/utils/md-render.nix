{
  lib,
  pkgs,
  ...
}:
{
  extraPackages = with pkgs; [
    python3Packages.pylatexenc
  ];
  plugins.render-markdown = {
    enable = true;
    settings = {
      completions.lsp.enabled = true;
      preset = "lazy";
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>mp";
      action = "<cmd>RenderMarkdown toggle<cr>";
      options = {
        desc = "Toggle Markdown preview";
      };
    }
  ];
}
