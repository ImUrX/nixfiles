{
  plugins.neorg = {
    enable = true;
    telescopeIntegration.enable = true;
    settings = {
      load = {
        "core.concealer" = {
          config = {
            icon_preset = "varied";
          };
        };
        "core.completion" = {
          config = {
            engine = "nvim-cmp";
          };
        };
        "core.defaults".__empty = null;
        "core.integrations.nvim-cmp".__empty = null;
        "core.integrations.image".__empty = null;
        "core.integrations.treesitter".__empty = null;
        "core.latex.renderer".__empty = null;
        "core.dirman" = {
          config = {
            workspaces = {
              notes = "~/proyects/notes/";
            };
            default_workspace = "notes";
          };
        };
      };
    };
  };
}
