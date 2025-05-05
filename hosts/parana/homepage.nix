{config, ...}: {
  services.homepage-dashboard.enable = true;
  services.homepage-dashboard.environmentFile = config.age.secrets.homepage.path;

  services.homepage-dashboard.settings = {
    title = "Home";
    description = "Starting page of the local net";
    statusStyle = "dot";
  };

  services.homepage-dashboard.widgets = [
    {
      resources = {
        cpu = true;
        memory = true;
        network = true;

        cputemp = true;
        tempmin = 20;
        tempmax = 75;

        label = "System";
      };
    }
    {
      resources = {
        disk = "/";
        label = "Root";
      };
    }
    {
      resources = {
        disk = "/data";
        label = "Data";
      };
    }
  ];

  services.homepage-dashboard.services = [
    {
      "Services" = [
        {
          "Paperless" = rec {
            icon = "paperless-ng";
            href = "https://paper.2dgirls.date";
            siteMonitor = "http://192.168.100.11:28981";
            widget = {
              type = "paperlessngx";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_PAPER}}";
            };
          };
        }
      ];
    }
    {
      "Home" = [
        {
          "Home Assistant" = rec {
            icon = "home-assistant";
            href = "https://home.2dgirls.date";
            siteMonitor = href;
            widget = {
              type = "homeassistant";
              url = href;
              key = "{{HOMEPAGE_VAR_HA}}";
              custom = [
                {state = "sensor.energy_today";}
                {
                  state = "sensor.fusiblebken_current";
                  label = "amperaje";
                }
                {
                  template = "{{ states.light|selectattr('state','equalto','on')|list|length }}";
                  label = "lights on";
                }
              ];
            };
          };
        }
      ];
    }
  ];
}
