{
  config,
  pkgs,
  lib,
  ...
}:
let
  app = "nginx";
  curPhp = (
    pkgs.php85.withExtensions (
      { all, enabled }:
      enabled
      ++ (with all; [
        gd
        mysqlnd
        mbstring
        bcmath
        curl
        zip
        intl
        sqlite3
      ])
    )
  );
in
{
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  services.cloudflared = {
    enable = true;
    tunnels = {
      "8f735f1f-39b5-4402-bc8f-b5e7dd254da5" = {
        credentialsFile = "${config.age.secrets.cloudflared.path}";
        default = "http_status:404";
      };
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.phpfpm.pools.${app} = {
    user = "nginx";
    phpPackage = curPhp;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    # phpEnv."PATH" = lib.makeBinPath [ pkgs.php85 ];
  };

  services.nginx = {
    enable = true;
    commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v4";
            sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
          }
        );
        cfipv6 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v6";
            sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
          }
        );
      in
      ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
      '';
    virtualHosts."pel.2dgirls.date" = {
      root = "/var/www/pelican/public";
      extraConfig = ''
        index index.html index.htm index.php;
        charset utf-8;

        access_log off;
        error_log  /var/log/nginx/pelican.app-error.log error;

        client_max_body_size 100m;
        client_body_timeout 120s;

        sendfile off;
      '';
      locations = {
        "/" = {
          tryFiles = "$uri $uri/ /index.php?$query_string";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_redirect off;
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };
        "/favicon.ico" = {
          extraConfig = "access_log off; log_not_found off;";
        };
        "/robots.txt" = {
          extraConfig = "access_log off; log_not_found off;";
        };
        "~ \\.php$" = {
          fastcgiParams = {
            PHP_VALUE = "upload_max_filesize = 100M \\n post_max_size=100M";
            HTTP_PROXY = "";
          };
          extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
            fastcgi_index index.php;
            include ${pkgs.nginx}/conf/fastcgi.conf;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
          '';
        };
        "~ /\\.ht" = {
          extraConfig = "deny all;";
        };
      };
      listen = [
        {
          addr = "0.0.0.0";
          port = 5136;
        }
      ];
    };
  };

  systemd.timers.pelican-schedule = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "pelican-schedule.service";
    };
  };

  systemd.services = {
    pelican-schedule = {
      script = ''
        ${curPhp}/bin/php /var/www/pelican/artisan schedule:run
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "nginx";
      };
    };
    pelican-queue = {
      description = "Pelican Queue Service";
      script = "${curPhp}/bin/php /var/www/pelican/artisan queue:work --tries=3";
      startLimitIntervalSec = 180;
      startLimitBurst = 30;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "nginx";
        Group = "nginx";
        Restart = "always";
        RestartSec = "5s";
      };
    };
    wings = {
      description = "Wings Daemon";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];

      serviceConfig = {
        User = "root";
        WorkingDirectory = "/etc/pelican";
        LimitNOFILE = 4096;
        PIDFile = "/var/run/wings/daemon.pid";
        ExecStart = "/usr/local/bin/wings";
        Restart = "on-failure";
        StartLimitIntervalSec = 180;
        StartLimitBurst = 30;
        RestartSec = "5s";
      };

      wantedBy = [ "multi-user.target" ];

      # Ensure necessary directories exist and are owned by the wings user
      preStart = ''
        mkdir -p /etc/pelican /var/run/wings
      '';
    };
  };

  environment.systemPackages = [
    curPhp
    curPhp.packages.composer
  ];

  # nixarr.enable = true;
  # nixarr.plex.enable = true;

  # systemd.services.update-mirror = {
  #   serviceConfig = {
  #     Type = "oneshot";
  #   };
  #   startAt = "*-*-* 00:00:00";
  #   script = "${pkgs.rsync}/bin/rsync -za --progress rsync://parana.ruffe-dojo.ts.net/movies/ /data/media/library/movies";
  # };
}
