#!/usr/bin/env bash
# Upload PNG charts to the public repo nikolaihack/weiterweg-media and print their public URLs.
# Usage: upload.sh file1.png [file2.png ...]   (existing names are overwritten)
set -euo pipefail
REPO_DIR=/home/box/weiterweg-media
TOKEN=$(cat "$HOME/.config/weiterweg-media/github-token")
AUTH=$(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)
cd "$REPO_DIR"
git -c http.extraHeader="Authorization: Basic $AUTH" pull -q --rebase https://github.com/nikolaihack/weiterweg-media.git main
for f in "$@"; do
  name=$(basename "$f" | tr ' ' '-')
  case "$name" in *.png|*.PNG|*.jpg|*.jpeg|*.webp) ;; *) echo "skip (not an image): $f" >&2; continue;; esac
  cp "$f" "charts/$name"; git add "charts/$name"
done
git diff --cached --quiet || git -c user.name=weiterweg -c user.email=weiterweg@users.noreply.github.com commit -qm "charts: $(date +%F\ %H:%M)"
git -c http.extraHeader="Authorization: Basic $AUTH" push -q https://github.com/nikolaihack/weiterweg-media.git main
sha=$(git rev-parse HEAD)
for f in "$@"; do name=$(basename "$f" | tr ' ' '-')
  echo "https://raw.githubusercontent.com/nikolaihack/weiterweg-media/$sha/charts/$name"; done
