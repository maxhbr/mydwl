{ src, lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, wayland-protocols, wayland, libpulseaudio }:
stdenv.mkDerivation rec {
  pname = "sway-audio-idle-inhibit";
  version = "git";

  inherit src;

  nativeBuildInputs = [ meson ninja pkg-config wayland-protocols wayland libpulseaudio ];

  meta = with lib; {
    description = "Prevents swayidle from sleeping while any application is outputting or receiving audio.";
    homepage = "https://github.com/ErikReider/SwayAudioIdleInhibit";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}