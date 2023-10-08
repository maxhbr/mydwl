{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, wayland-protocols, wayland, libpulseaudio }:
stdenv.mkDerivation rec {
  pname = "sway-audio-idle-inhibit";
  version = "git";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayAudioIdleInhibit";
    rev = "c850bc4812216d03e05083c69aa05326a7fab9c7";
    sha256 = "sha256-MKzyF5xY0uJ/UWewr8VFrK0y7ekvcWpMv/u9CHG14gs=";
  };

  # dontConfigure = true;
  nativeBuildInputs = [ meson ninja pkg-config wayland-protocols wayland libpulseaudio ];
  # NIX_CFLAGS_COMPILE = [ "-Wno-unused-result" ];

  # installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Prevents swayidle from sleeping while any application is outputting or receiving audio.";
    homepage = "https://github.com/ErikReider/SwayAudioIdleInhibit";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}