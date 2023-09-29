{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # TODO: mysomebar as non-flake input
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    # TODO: is not a derivation or path
    packages.x86_64-linux.dwl = (pkgs.dwl.overrideAttrs (prev: {
          version = "git";
          src = ./.;
          enableXWayland = true;
          # conf = ./myconfig.h;
    }));
    packages.x86_64-linux.mydwl = self.packages.x86_64-linux.dwl.override { conf = ./myconfig.h; };
    packages.x86_64-linux.mysomebar =  (pkgs.somebar.overrideAttrs (prev: {
      version = "git";
      src = pkgs.fetchFromSourcehut {
        owner = "~raphi";
        repo = "somebar";
        rev = "8c52d4704c0ac52c946e41a1a68c8292eb83d0d2";
        hash = "sha256-9KYuX2bwRKiHiRHsFthdZ+TVkJE8Cjm+f78f9qhbB90=";
      };
      # patches = [
      #   (pkgs.fetchpatch {
      #         url = "https://git.sr.ht/~raphi/somebar/blob/master/contrib/clickable-tags-using-wtype.patch";
      #         hash = "sha256-4M59rZukfyJAXG7ZwMjgzeu8wQKx6F0OBVbaNw0xZ7k=";
      #       })
      # ];
  }));
    packages.x86_64-linux.default = self.packages.x86_64-linux.mydwl;
    nixosModules.mydwl = {config, pkgs, lib, ...}: let
      cfg = config.mydwl;
      mydwl = self.packages.x86_64-linux.mydwl;
      mysomebar = self.packages.x86_64-linux.mysomebar;
      mydwl-autostart = pkgs.writeShellScriptBin "mydwl-autostart" ''
set -x
${cfg.autostartCommands}
${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
'';
      mydwl-start = pkgs.writeShellScriptBin "mydwl-start" ''
PATH="$PATH:${mydwl-autostart}/bin"
exec ${mydwl}/bin/dwl -s ${mysomebar}/bin/somebar
'';
    in {
      options.mydwl = with lib; {
        enable = mkEnableOption "mydwl";
        startCommand = mkOption {
          type = type.str;
          default = "${pkgs.mydwl-start}/bin/mydwl-start";
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
              inherit mydwl mysomebar mydwl-autostart mydwl-start;
            })
          ];
          home-manager.sharedModules = [{ home.packages = with pkgs; [ mydwl mysomebar mydwl-start ]; }];
        });
    };
    nixosModules.default = self.nixosModules.mydwl;
  };
}
