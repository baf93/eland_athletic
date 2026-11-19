#!/usr/bin/env bash
# Renders every Play Store graphic from src/store.html into graphics/.
set -euo pipefail
cd "$(dirname "$0")/.."
R="swift tools/render.swift src/store.html"
$R graphics/icon-512.png 512 512 "#icon"
for lang in en it; do
  mkdir -p "graphics/$lang"
  $R "graphics/$lang/feature-1024x500.png" 1024 500 "#feature-$lang"
  for n in 1 2 3 4 5 6 7 8; do
    $R "graphics/$lang/$n.png" 1080 1920 "#shot-$lang-$n"
  done
done
echo "done"
