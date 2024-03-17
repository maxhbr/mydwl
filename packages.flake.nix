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
  dwl = (pkgs.dwl.overrideAttrs (prev: {
      version = "git";
      src = inputs.dwl;
      enableXWayland = true;
  }));
  dwl-patched = self.packages.x86_64-linux.dwl.overrideAttrs (oldAttrs: rec {
    patches = [
      # "${inputs.dwl-patches}/vanitygaps/vanitygaps.patch"
      "${inputs.dwl-patches}/centeredmaster/centeredmaster.patch"
      "${inputs.dwl-patches}/rotatetags/rotatetags.patch"
    ];
  });
  mydwl = self.packages.x86_64-linux.dwl-patched.override { conf = ./myconfig.h; };

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
