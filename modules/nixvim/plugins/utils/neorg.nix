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
        "core.defaults" = {
          __empty = null;
        };
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