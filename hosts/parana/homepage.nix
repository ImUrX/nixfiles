{ config, ... }:
{
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
      "Arr" = [
        {
          "Radarr" = rec {
            icon = "radarr";
            href = "https://radarr.2dgirls.date";
            siteMonitor = "http://localhost:7878";
            widget = {
              type = "radarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_RADARR}}";
            };
          };
        }
        {
          "Sonarr" = rec {
            icon = "sonarr";
            href = "https://sonarr.2dgirls.date";
            siteMonitor = "http://localhost:8989";
            widget = {
              type = "sonarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_SONARR}}";
            };
          };
        }
        {
          "Bazarr" = rec {
            icon = "bazarr";
            href = "https://bazarr.2dgirls.date";
            siteMonitor = "http://localhost:6767";
            widget = {
              type = "bazarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_BAZARR}}";
            };
          };
        }
        {
          "Lidarr" = rec {
            icon = "lidarr";
            href = "https://lidarr.2dgirls.date";
            siteMonitor = "http://localhost:8686";
            widget = {
              type = "lidarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_LIDARR}}";
            };
          };
        }
        {
          "Readarr" = rec {
            icon = "readarr";
            href = "https://readarr.2dgirls.date";
            siteMonitor = "http://localhost:8787";
            widget = {
              type = "readarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_READARR}}";
            };
          };
        }
        {
          "Prowlarr" = rec {
            icon = "prowlarr";
            href = "https://prowlarr.2dgirls.date";
            siteMonitor = "http://localhost:9696";
            widget = {
              type = "prowlarr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_PROWLARR}}";
            };
          };
        }
        {
          "Autobrr" = rec {
            icon = "autobrr";
            href = "https://autoarr.2dgirls.date";
            siteMonitor = "http://localhost:7474";
            widget = {
              type = "autobrr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_AUTOBRR}}";
            };
          };
        }
      ];
    }
    {
      "Downloaders" = [
        {
          "Transmission" = rec {
            icon = "transmission";
            href = "https://deluge.2dgirls.date";
            siteMonitor = "http://localhost:9091";
            widget = {
              type = "transmission";
              url = siteMonitor;
            };
          };
        }
        {
          "SABnzbd" = rec {
            icon = "sabnzbd";
            href = "https://nz.2dgirls.date";
            siteMonitor = "http://localhost:6336";
            widget = {
              type = "sabnzbd";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_SABNZBD}}";
            };
          };
        }
        {
          "slskd" = rec {
            icon = "slskd";
            href = "https://soul.2dgirls.date";
            siteMonitor = "http://192.168.16.1:5030";
            widget = {
              type = "slskd";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_SLSKD}}";
            };
          };
        }
        {
          "Jellyseerr" = rec {
            icon = "jellyseerr";
            href = "https://jelly.2dgirls.date";
            siteMonitor = "http://localhost:5055";
            widget = {
              type = "jellyseerr";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_JELLYSEERR}}";
            };
          };
        }
      ];
    }
    {
      "Streaming" = [
        {
          "Plex" = rec {
            icon = "plex";
            href = "https://app.plex.tv";
            siteMonitor = "http://localhost:32400";
            widget = {
              type = "plex";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_PLEX}}";
            };
          };
        }
        {
          "Tautulli" = rec {
            icon = "tautulli";
            href = "https://tautulli.2dgirls.date";
            siteMonitor = "http://localhost:8181";
            widget = {
              type = "tautulli";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_TAUTULLI}}";
            };
          };
        }
      ];
    }
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
        {
          "immich" = rec {
            icon = "immich";
            href = "https://img.2dgirls.date";
            siteMonitor = "http://192.168.101.11:2283";
            widget = {
              type = "immich";
              url = siteMonitor;
              key = "{{HOMEPAGE_VAR_IMMICH}}";
              version = 2;
            };
          };
        }
        {
          "Speedtest" = rec {
            icon = "speedtest-tracker";
            href = "https://speedtest.2dgirls.date";
            siteMonitor = "http://localhost:6814";
            widget = {
              type = "speedtest";
              url = siteMonitor;
              version = "2";
              key = "{{HOMEPAGE_VAR_SPEEDTEST}}";
            };
          };
        }
        {
          "Minecraft" = {
            icon = "minecraft";
            widget = {
              type = "minecraft";
              url = "udp://localhost:25565";
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
                { state = "sensor.energy_today"; }
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
