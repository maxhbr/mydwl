#!/usr/bin/env bash

set -euo pipefail

declare -a patches=(
  "sevz17:vanitygaps"
#   "sevz17:autostart"
  "NikitaIvanovV:centeredmaster"
  "korei999:rotatetags"
  "dm1tz:04-cyclelayouts"
#   "wochap:regexrules"
  "madcowog:ipc-v2"
  "PalanixYT:float_border_color"
)

addRemoteIfMissing() {
    local remote="$1"
    local url="${2:-"https://github.com/$remote/dwl"}"
    if ! git remote | grep -q "$remote"; then
        git remote add "$remote" "$url"
    fi
}

applyPatch() {
    local remote="$1"
    local branch="$2"
    addRemoteIfMissing "$remote"
    git fetch "$remote" "$branch"

    # check if patch is already applied
    if git branch --contains "$remote/$branch" | grep -q '^\*'; then
        echo "patch $branch from $remote already applied"
    else
        echo "apply $branch from $remote"
        git merge --no-edit "$remote/$branch"
        nix build .#dwl
    fi
}

cd "$(dirname "$0")"
addRemoteIfMissing "upstream" "https://github.com/djpohly/dwl"
applyPatch "upstream" "main"

# read patches into pairs of remote and branch
while IFS=':' read -r remote branch; do
  applyPatch "$remote" "$branch"
done < <(printf '%s\n' "${patches[@]}")

nix build .#dwl
nix build .#mydwl
