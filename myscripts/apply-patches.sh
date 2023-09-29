#!/usr/bin/env bash

set -euo pipefail

declare -a patches=(
  "https://github.com/djpohly/dwl/compare/main...sevz17:vanitygaps.patch"
  "https://github.com/djpohly/dwl/compare/main...sevz17:autostart.patch"
  "https://github.com/djpohly/dwl/compare/main...korei999:rotatetags.patch"
  "https://github.com/djpohly/dwl/compare/main...NikitaIvanovV:centeredmaster.patch"
  "https://github.com/djpohly/dwl/compare/main...juliag2:alphafocus.patch"
  "https://github.com/djpohly/dwl/compare/main...dm1tz:04-cyclelayouts.patch"
  "https://github.com/djpohly/dwl/compare/main...faerryn:cursor_warp.patch"
  "https://github.com/djpohly/dwl/compare/main...madcowog:ipc-v2.patch"
  "https://github.com/djpohly/dwl/compare/main...PalanixYT:float_border_color.patch"
)

cd "$(dirname "$0")/.."
for i in "${patches[@]}"; do
  echo "Applying patch: $i"
  curl -s $i | git apply
done


