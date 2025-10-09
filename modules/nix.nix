# Configuration of how nix does nix stuff
{
  inputs,
  ...
}:
{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      sandbox = true;

      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    nixPath = [
      "nixpkgs=/run/current-system/sw/nixpkgs"
    ]; # Pin the <nixpkgs> channel to our nixpkgs
    # Garbage collect and optimize
    gc = {
      automatic = true;
      options = "--delete-older-than 8d";
      dates = "weekly";
    };

    registry.nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = {
        type = "path";
        path = "${inputs.nixpkgs}";
      };
    };

    optimise.automatic = true;
  };

  environment.extraSetup = ''
    ln -s ${inputs.nixpkgs} $out/nixpkgs
  '';
}
