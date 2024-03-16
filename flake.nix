{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    dwl.url = "git+https://codeberg.org/dwl/dwl";
    dwl.flake = false;
    dwl-patches.url = "git+https://codeberg.org/dwl/dwl-patches";
    dwl-patches.flake = false;

    somebar.url = "sourcehut:~raphi/somebar";
    somebar.flake = false;

    sway-audio-idle-inhibit.url = "github:ErikReider/SwayAudioIdleInhibit";
    sway-audio-idle-inhibit.flake = false;
  };

  outputs = inputs: {
    packages = import ./packages.flake.nix inputs;
    nixosModules = import ./nixosModules.flake.nix inputs;
  };
}
