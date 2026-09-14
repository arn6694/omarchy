#!/bin/bash
# Install the reviewed Nerd Fonts release in the current user's account.
set -euo pipefail
(( EUID != 0 )) || { echo 'Run as the desktop user.' >&2; exit 1; }
version=v3.4.0
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
for font in JetBrainsMono FiraCode Meslo; do
  curl --fail --location --proto '=https' --tlsv1.2 \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/$version/$font.tar.xz" -o "$stage/$font.tar.xz"
  mkdir -p "$HOME/.local/share/fonts/NerdFonts/$font"
  tar -xJf "$stage/$font.tar.xz" -C "$HOME/.local/share/fonts/NerdFonts/$font" --no-same-owner
 done
fc-cache -f
omarchy-font-set 'JetBrainsMono Nerd Font'
