{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    somebar.url = "sourcehut:~raphi/somebar";
    somebar.flake = false;

    sway-audio-idle-inhibit.url = "github:ErikReider/SwayAudioIdleInhibit";
    sway-audio-idle-inhibit.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    packages.x86_64-linux = {
      dwl = (pkgs.dwl.overrideAttrs (prev: {
          version = "git";
          src = ./.;
          enableXWayland = true;
      }));
      mydwl = self.packages.x86_64-linux.dwl.override { conf = ./myconfig.h; };
      mysomebar =  (pkgs.somebar.overrideAttrs (prev: {
        version = "git";
        src = inputs.somebar;
        nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeWrapper ];
        postInstall = ''
makeWrapper $out/bin/somebar $out/bin/mysomebar \
  --add-flags '-s "/tmp/somebar.''${XDG_VTNR}.''${USER}.fifo"'
        '';
      }));
      sway-audio-idle-inhibit = pkgs.callPackage ./SwayAudioIdleInhibit { src = inputs.sway-audio-idle-inhibit; };
    };
    nixosModules.mydwl = {config, pkgs, lib, ...}: with self.packages.x86_64-linux; let
      cfg = config.mydwl;
      mydwl-start = let
        mydwl-autostart = pkgs.writeShellScriptBin "mydwl-autostart" ''
# swallow stdin
exec <&-
set -x
${cfg.autostartCommands}
'';
        mydwl-autostart-pipe = pkgs.writeShellScriptBin "mydwl-autostart-pipe" ''
set -x
tee "/tmp/dwl.''${XDG_VTNR}.''${USER}.stdout" | ${mydwl-autostart}/bin/mydwl-autostart
'';
      in pkgs.writeShellScriptBin "mydwl-start" ''
exec &> >(tee -a "/tmp/dwl.''${XDG_VTNR}.''${USER}.log")
set -x
  exec ${mydwl}/bin/dwl -s ${mydwl-autostart-pipe}/bin/mydwl-autostart-pipe
'';
    in {
      options.mydwl = with lib; {
        enable = mkEnableOption "mydwl";
        startCommand = mkOption {
          type = types.path;
          default = "${pkgs.mydwl-start}/bin/mydwl-start";
        };
        barCommand = mkOption {
          type = types.nullOr types.path;
          default = "${pkgs.mysomebar}/bin/mysomebar";
        };
        addWaybarModulesForDwlWaybar = mkEnableOption "add waybar modules, to use dwl-waybar";
        autostartCommands = mkOption {
          type = types.lines;
          default = with pkgs; ''
            ${playerctl}/bin/playerctld daemon &
            ${foot}/bin/foot --server &
            {
              tfoot || ${pkgs.foot}/bin/foot
            } >/dev/null 2>&1 &
            ${wlsunset}/bin/wlsunset &
          '';
        };
      };
      config =
        (lib.mkIf cfg.enable {
          nixpkgs.overlays = [
            (_: _: {
              inherit mydwl mydwl-start sway-audio-idle-inhibit;
            })
          ];
          home-manager.sharedModules = [({config, ...}: {
            home.packages = with pkgs; [ mydwl mydwl-start sway-audio-idle-inhibit ];
            programs.waybar.settings.mainBar = {
              # modules-left = lib.mkForce [ ]; # "dwl/tags" ];
              # modules-center = lib.mkForce [ ];
              "dwl/tags" = {
                num-tags = 9;
                tag-labels = [ "U" "I" "A" "E" "O" "S" "N" "R" "T" ];
              };
              "custom/audio_idle_inhibitor" = {
                format = "{icon}";
                exec = "${sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit --dry-print-both-waybar";
                return-type = "json";
                format-icons = {
                  output = "";
                  input = "";
                  output-input = "  ";
                  none = "";
                };
              };
            };
          })];
        });
    };
  };
}