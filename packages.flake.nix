pkgs:
{ self, nixpkgs, ... }@inputs:
{
  dwl = (pkgs.dwl.overrideAttrs (prev: {
      version = "git";
      src = ./.;
      enableXWayland = true;
  }));
  dwl-git = (pkgs.dwl.overrideAttrs (prev: {
      version = "git";
      src = inputs.dwl;
      enableXWayland = true;
  }));
  mydwl = self.packages.x86_64-linux.dwl.override { conf = ./myconfig.h; };
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
}
