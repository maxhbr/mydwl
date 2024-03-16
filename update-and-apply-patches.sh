#!/usr/bin/env bash

set -euo pipefail

addRemoteIfMissing() {
    local remote="$1"
    local url="${2:-"https://github.com/$remote/dwl"}"
    if ! git remote | grep -q "$remote"; then
        git remote add "$remote" "$url"
    fi
}

applyPatchfile() {
  local patchfile="$1"
  echo "applyPatchfile patchfile=$patchfile ..."

  # Check if the patch can be applied cleanly
  if git apply --check "$patchfile" >/dev/null 2>&1; then
      echo "apply ..."
      # Apply the patch
      if git apply "$patchfile"; then
          echo "... successfully."
      else
          echo "Failed to apply the patch."
          exit 1
      fi
  else
      echo "... Patch cannot be applied cleanly or is already applied. Skipping."
  fi
}

applyPatch() {
    local remote="$1"
    local branch="$2"
    echo "applyPatch remote=$remote and branch=$branch ..."
    addRemoteIfMissing "$remote"
    git fetch "$remote" "$branch"

    # check if patch is already applied
    if git branch --contains "$remote/$branch" | grep -q '^\*'; then
        echo "... already applied"
    else
        echo "apply ..."
        git merge --no-edit "$remote/$branch"
        nix build ".#dwl"
    fi
}

applyUpstream() {
  addRemoteIfMissing "upstream" "https://github.com/djpohly/dwl"
  applyPatch "upstream" "main"
}

applyPatches() {
  declare -a patches=(
    ./dwl-patches/vanitygaps/vanitygaps.patch
    # "sevz17:vanitygaps"
  # #   "sevz17:autostart"
    # "NikitaIvanovV:centeredmaster"
    # "korei999:rotatetags"
    # "dm1tz:04-cyclelayouts"
  # #   "wochap:regexrules"
    # "madcowog:ipc-v2"
    # "PalanixYT:float_border_color"
  )

  # read patches into pairs of remote and branch
  while IFS=':' read -r remote branch; do
    if [[ -z "$branch" ]]; then
      applyPatchfile "$remote"
    else
      echo applyPatch "$remote" "$branch"
    fi
  done < <(printf '%s\n' "${patches[@]}")
}

cd "$(dirname "$0")"
echo applyUpstream
applyPatches

echo nix build .#dwl
echo nix build .#mydwl
