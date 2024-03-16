{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    dwl.url = "https://codeberg.org/dwl/dwl";
    dwl.flake = false;
    dwl-patches.url = "https://codeberg.org/dwl/dwl-patches";
    dwl-patches.flake = false;

    somebar.url = "sourcehut:~raphi/somebar";
    somebar.flake = false;

    sway-audio-idle-inhibit.url = "github:ErikReider/SwayAudioIdleInhibit";
    sway-audio-idle-inhibit.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };

  in {
    packages.x86_64-linux = import ./packages.flake.nix pkgs inputs;
    nixosModules = import ./nixosModules.flake.nix pkgs inputs;
  };
}
