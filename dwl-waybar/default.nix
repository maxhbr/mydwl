{ stdenv, inotify-tools, substituteAll }:

stdenv.mkDerivation {
  name = "dwl-waybar";

  buildCommand = ''
    install -Dm755 $script $out/bin/dwl-waybar
  '';

  script = substituteAll {
    src = ./dwl-waybar.sh;
    isExecutable = true;
    inotify = inotify-tools;
    inherit (stdenv) shell;
  };

  # meta = with stdenv.lib; {
  #   description = "script for using waybar with dwl";
  #   platforms = platforms.all;
  #   license = licenses.gpl3;
  #   maintainers = with maintainers; [  ];
  # };
}
