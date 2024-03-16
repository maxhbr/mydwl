{ self, nixpkgs, ... }@inputs:
let
  forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix;

  nixpkgsFor = forAllSystems (system: import nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  });
in
forAllSystems (system:
let pkgs = nixpkgsFor."${system}"; in {
  # build from this repo:
  dwl = (pkgs.dwl.overrideAttrs (prev: {
      version = "git";
      src = ./.;
      enableXWayland = true;
  }));
  mydwl = self.packages.x86_64-linux.dwl.override { conf = ./myconfig.h; };

  # build from git pulled in via flake:
  dwl-git = (pkgs.dwl.overrideAttrs (prev: {
      version = "git";
      src = inputs.dwl;
      enableXWayland = true;
  }));
  mydwl-git = self.packages.x86_64-linux.dwl-git.override { conf = ./myconfig.h; };

  mysomebar =  (pkgs.somebar.overrideAttrs (prev: {
    version = "git";
    src = inputs.somebar;
    nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeWrapper ];
    postInstall = ''
Wrapper $out/bin/somebar $out/bin/mysomebar \
add-flags '-s "/tmp/somebar.''${XDG_VTNR}.''${USER}.fifo"'
    '';
  }));
  sway-audio-idle-inhibit = pkgs.callPackage ./SwayAudioIdleInhibit { src = inputs.sway-audio-idle-inhibit; };
  default = self.packages.x86_64-linux.mydwl;
    })
