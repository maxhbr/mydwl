{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    somebar.url = "sourcehut:~raphi/somebar";
    somebar.flake = false;
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    # TODO: is not a derivation or path
    packages.x86_64-linux = {
      dwl = (pkgs.dwl.overrideAttrs (prev: {
          version = "git";
          src = ./.;
          enableXWayland = true;
          # conf = ./myconfig.h;
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
      dwl-waybar = pkgs.callPackage ./dwl-waybar { };
      dwl-state = pkgs.callPackage ./dwl-state { };
      someblocks = pkgs.callPackage ./someblocks { };
      default = self.packages.x86_64-linux.mydwl;
    };
    nixosModules.mydwl = {config, pkgs, lib, ...}: with self.packages.x86_64-linux; let
      cfg = config.mydwl;
      mydwl-autostart = pkgs.writeShellScriptBin "mydwl-autostart" ''
# swallow stdin
exec <&-
set -x
${cfg.autostartCommands}
${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
'';
      mydwl-start = let
        wrappedBarCommand = pkgs.writeShellScriptBin "mydwl-wrappedBarCommand" ''
set -x
tee "/tmp/dwl.''${XDG_VTNR}.''${USER}.stdout" | ${cfg.barCommand}
'';
        directStdout = (if cfg.barCommand == null then "| tee /tmp/dwl.\${XDG_VTNR}.\${USER}.stdout" else "-s ${wrappedBarCommand}/bin/mydwl-wrappedBarCommand");
      in pkgs.writeShellScriptBin "mydwl-start" ''
PATH="$PATH:${mydwl-autostart}/bin"
exec &> >(tee -a "/tmp/dwl.''${XDG_VTNR}.''${USER}.log")
set -x
${mydwl}/bin/dwl ${directStdout}
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
              inherit mydwl mysomebar mydwl-autostart mydwl-start dwl-waybar dwl-state someblocks;
            })
          ];
          home-manager.sharedModules = [{
            home.packages = with pkgs; [ mydwl mysomebar mydwl-start dwl-waybar someblocks ];
            programs.waybar.settings =lib.mkIf cfg.addWaybarModulesForDwlWaybar {
              mainBar = lib.mkMerge ([{
                modules-left = (builtins.map (i: "custom/dwl_tag#${toString i}")
                  (builtins.genList (i: i) 9));
                modules-center = [ "custom/dwl_title" ];
                "custom/dwl_layout" = {
                  exec = "${dwl-waybar}/bin/dwl-waybar '' layout";
                  format = "{}";
                  escape = true;
                  return-type = "json";
                };
                "custom/dwl_title" = {
                  exec = "${dwl-waybar}/bin/dwl-waybar '' title";
                  format = "{}";
                  escape = true;
                  return-type = "json";
                  max-length = 50;
                };
                "custom/dwl_mode" = {
                  exec = "${dwl-waybar}/bin/dwl-waybar '' mode";
                  format = "{}";
                  escape = true;
                  return-type = "json";
                };
              }] ++ (builtins.map (i: {
                "custom/dwl_tag#${toString i}" = {
                  exec = "${dwl-waybar}/bin/dwl-waybar '' ${toString i}";
                  format = "{}";
                  return-type = "json";
                };
              }) (builtins.genList (i: i) 9)));
            };
          }];
        });
    };
    nixosModules.default = self.nixosModules.mydwl;
  };
}
