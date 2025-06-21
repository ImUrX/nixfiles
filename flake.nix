# This can be built with nixos-rebuild --flake .#myhost build
{
  description = "the simplest flake for nixos-rebuild";

  inputs = {
    self.submodules = true;

    nixpkgs = {
      # Using the nixos-unstable branch specifically, which is the
      # closest you can get to following the equivalent channel with flakes.
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # emacs-overlay.url = "github:nix-community/emacs-overlay";

    pipewire-screenaudio.url = "github:IceDBorn/pipewire-screenaudio";
    pipewire-screenaudio.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    more-waita = {
      url = "github:somepaulo/MoreWaita";
      flake = false;
    };

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    minegrub-theme.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    nixarr.url = "github:rasmus-kirk/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";
    nixarr.inputs.vpnconfinement.follows = "vpn-confinement";

    rfm.url = "github:dsxmachina/rfm";
    rfm.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs can be anything, but the wiki + some commands define their own
  # specific keys. Wiki page: https://nixos.wiki/wiki/Flakes#Output_schema
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      aagl,
      nixos-hardware,
      nix-alien,
      musnix,
      agenix,
      vpn-confinement,
      nixarr,
      nixpkgs-xr,
      nur,
      ...
    }@inputs:
    {
      # nixosConfigurations is the key that nixos-rebuild looks for.
      nixosConfigurations = {
        uridesk = nixpkgs.lib.nixosSystem rec {
          # A lot of times online you will see the use of flake-utils + a
          # function which iterates over many possible systems. My system
          # is x86_64-linux, so I'm only going to define that
          system = "x86_64-linux";
          # Import our old system configuration.nix
          modules = [
            ./hosts/uridesk
            ./configuration.nix
            ./users/uri
            home-manager.nixosModules.home-manager
            musnix.nixosModules.musnix
            nixpkgs-xr.nixosModules.nixpkgs-xr
            nur.modules.nixos.default
            {
              environment.systemPackages = [
                agenix.packages.${system}.default
              ];
            }
            {
              _module.args = {
                inherit inputs;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # home-manager.users.uri = import ./home.nix

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = {
                inherit inputs;
                headless = false;
              };
            }
            {
              imports = [ aagl.nixosModules.default ];
              nix.settings = aagl.nixConfig; # Setup cachix
              programs.anime-game-launcher.enable = true;
              programs.sleepy-launcher.enable = true;
            }
            {
              environment.systemPackages = [ nix-alien.packages.${system}.nix-alien ];
            }
          ];
        };
        minidesk = nixpkgs.lib.nixosSystem rec {
          # A lot of times online you will see the use of flake-utils + a
          # function which iterates over many possible systems. My system
          # is x86_64-linux, so I'm only going to define that
          system = "x86_64-linux";
          # Import our old system configuration.nix
          modules = [
            ./hosts/minidesk
            ./configuration.nix
            ./users/uri
            nixos-hardware.nixosModules.framework-13th-gen-intel
            home-manager.nixosModules.home-manager
            musnix.nixosModules.musnix
            nur.modules.nixos.default
            {
              environment.systemPackages = [
                agenix.packages.${system}.default
              ];
            }
            {
              _module.args = {
                inherit inputs;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              # home-manager.users.uri = import ./home.nix

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
              home-manager.extraSpecialArgs = {
                inherit inputs;
                headless = false;
              };
            }
          ];
        };
        lal1tx = nixpkgs.lib.nixosSystem {
          # A lot of times online you will see the use of flake-utils + a
          # function which iterates over many possible systems. My system
          # is x86_64-linux, so I'm only going to define that
          system = "x86_64-linux";
          # Import our old system configuration.nix
          modules = [
            ./hosts/lal1tx
            ./configuration.nix
            ./users/home-lal1tx.nix
            home-manager.nixosModules.home-manager
            musnix.nixosModules.musnix
            nur.modules.nixos.default
            {
              _module.args = {
                inherit inputs;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                headless = false;
              };
            }
            {
              imports = [ aagl.nixosModules.default ];
              nix.settings = aagl.nixConfig; # Setup cachix
              programs.anime-game-launcher.enable = true;
              programs.sleepy-launcher.enable = true;
            }
          ];
        };
        atrii-trans = nixpkgs.lib.nixosSystem {
          # A lot of times online you will see the use of flake-utils + a
          # function which iterates over many possible systems. My system
          # is x86_64-linux, so I'm only going to define that
          system = "x86_64-linux";
          # Import our old system configuration.nix
          modules = [
            ./hosts/atrii-trans
            ./configuration.nix
            ./users/home-lal1tx.nix
            home-manager.nixosModules.home-manager
            musnix.nixosModules.musnix
            nur.modules.nixos.default
            {
              _module.args = {
                inherit inputs;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                headless = false;
              };
            }
            {
              imports = [ aagl.nixosModules.default ];
              nix.settings = aagl.nixConfig; # Setup cachix
              programs.sleepy-launcher.enable = true;
            }
            inputs.minegrub-theme.nixosModules.default
          ];
        };
        parana = nixpkgs.lib.nixosSystem {
          # A lot of times online you will see the use of flake-utils + a
          # function which iterates over many possible systems. My system
          # is x86_64-linux, so I'm only going to define that
          system = "x86_64-linux";
          # Import our old system configuration.nix
          modules = [
            ./hosts/parana
            ./headless.nix
            ./users/uri
            home-manager.nixosModules.home-manager
            musnix.nixosModules.musnix
            agenix.nixosModules.default
            nixarr.nixosModules.default
            nur.modules.nixos.default
            vpn-confinement.nixosModules.default
            {
              _module.args = {
                inherit inputs;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                headless = true;
              };

              age.secrets = {
                homepage.file = ./secrets/homepage.age;
                cloudflared.file = ./secrets/cloudflared.age;
                vpn-ar.file = ./secrets/protonvpn-ar.age;
                vpn-slsk.file = ./secrets/vpn-slsk.age;
                soulseek = {
                  file = ./secrets/soulseek.age;
                  owner = "lidarr";
                  mode = "770";
                };
                soularr = {
                  file = ./secrets/soularr.age;
                  name = "config.ini";
                };
                speedtest = {
                  file = ./secrets/speedtest.age;
                };
              };
            }
          ];
        };
      };
    };
}
