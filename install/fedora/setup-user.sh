#!/bin/bash
set -euo pipefail
if (( EUID == 0 )); then
  echo "Run user setup from the Fedora desktop user's account." >&2
  exit 1
fi
: "${OMARCHY_PATH:?Set OMARCHY_PATH to the installed Omarchedora directory}"
backup="$HOME/.local/state/omarchy/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/share/applications"
for source in "$OMARCHY_PATH/config/"*; do
  name=${source##*/}
  if [[ -e $HOME/.config/$name || -L $HOME/.config/$name ]]; then
    cp -a -- "$HOME/.config/$name" "$backup/$name"
  fi
  cp -a -- "$source" "$HOME/.config/"
done
[[ ! -e $HOME/.bashrc ]] || cp -a -- "$HOME/.bashrc" "$backup/bashrc"
if ! grep -qF '/usr/share/omarchy/default/bash/rc' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'EOF'

# Omarchedora desktop shell defaults
source /usr/share/omarchy/default/bash/env-bootstrap
[[ $- != *i* ]] || source /usr/share/omarchy/default/bash/rc
EOF
fi
cp -a --update=none -- "$OMARCHY_PATH/applications/." "$HOME/.local/share/applications/"
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Videos/Screencasts" "$HOME/.config/omarchy/themes"
OMARCHY_THEME_HEADLESS=1 omarchy-theme-set 'Tokyo Night'
xdg-settings set default-web-browser chromium.desktop
update-desktop-database "$HOME/.local/share/applications"
touch "$HOME/.local/state/omarchy/fedora-user-ready"
printf 'Existing configuration backed up to %s\n' "$backup"
