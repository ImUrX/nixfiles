{config, ...}: {
  services.homepage-dashboard.enable = true;
  services.homepage-dashboard.environmentFile = config.age.secrets.homepage.path;

  services.homepage-dashboard.widgets = [
    {
      resources = {
        cpu = true;
        disk = "/";
        memory = true;
      };
    }
  ];

  services.homepage-dashboard.services = [
    {
      "Home" = {
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
                template = "{{ states.switch|selectattr('state','equalto','on')|list|length }}";
                label = "switches on";
              }
            ];
          };
        };
      };
    }
  ];
}
