#!/usr/bin/env bash

set -euo pipefail

declare -a patches=(
  "sevz17:vanitygaps"
  "sevz17:autostart"
  "korei999:rotatetags"
  "NikitaIvanovV:centeredmaster"
#   "juliag2:alphafocus"
  "dm1tz:04-cyclelayouts"
  "faerryn:cursor_warp"
  "madcowog:ipc-v2"
  "PalanixYT:float_border_color"
)

addRemoteIfMissing() {
    local remote="$1"
    local url="https://github.com/$remote/dwl"
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
        nix build --no-out-link .
    fi
}

cd "$(dirname "$0")/.."

# read patches into pairs of remote and branch
while IFS=':' read -r remote branch; do
  applyPatch "$remote" "$branch"
done < <(printf '%s\n' "${patches[@]}")


