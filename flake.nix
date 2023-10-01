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
        # patches = [
        #   (pkgs.fetchpatch {
        #         url = "https://git.sr.ht/~raphi/somebar/blob/master/contrib/clickable-tags-using-wtype.patch";
        #         hash = "sha256-4M59rZukfyJAXG7ZwMjgzeu8wQKx6F0OBVbaNw0xZ7k=";
        #       })
        # ];
      }));
      dwl-waybar = pkgs.callPackage ./dwl-waybar { };
      default = self.packages.x86_64-linux.mydwl;
    };
    nixosModules.mydwl = {config, pkgs, lib, ...}: with self.packages.x86_64-linux; let
      cfg = config.mydwl;
      mydwl-autostart = pkgs.writeShellScriptBin "mydwl-autostart" ''
set -x
${cfg.autostartCommands}
${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
'';
      mydwl-start = let
        dashS = (if cfg.barCommand == null then "" else "-s ${cfg.barCommand}");
      in pkgs.writeShellScriptBin "mydwl-start" ''
PATH="$PATH:${mydwl-autostart}/bin"
exec &> >(tee -a "/tmp/dwl.''${XDG_VTNR}.''${USER}.log")
set -x
exec ${mydwl}/bin/dwl ${dashS} | tee "/tmp/dwl.''${XDG_VTNR}.''${USER}.stdout"
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
          default = "${pkgs.mysomebar}/bin/somebar";
        };
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
              inherit mydwl mysomebar mydwl-autostart mydwl-start dwl-waybar;
            })
          ];
          home-manager.sharedModules = [{ home.packages = with pkgs; [ mydwl mysomebar mydwl-start dwl-waybar ]; }];
        });
    };
    nixosModules.default = self.nixosModules.mydwl;
  };
}
