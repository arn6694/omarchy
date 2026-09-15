#!/bin/bash
set -euo pipefail
if (( EUID == 0 )); then
  echo "Run user setup from the Fedora desktop user's account." >&2
  exit 1
fi
force=false
[[ ${1:-} != "--force" ]] || force=true
if [[ $force == false && -f $HOME/.local/state/omarchy/fedora-user-ready ]]; then exit 0; fi
: "${OMARCHY_PATH:?Set OMARCHY_PATH to the installed Omadora directory}"
backup="$HOME/.local/state/omarchy/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/share/applications"
for source in "$OMARCHY_PATH/config/"*; do
  name=${source##*/}
  if [[ -e $HOME/.config/$name || -L $HOME/.config/$name ]]; then
    [[ $force == true ]] || continue
    cp -a -- "$HOME/.config/$name" "$backup/$name"
  fi
  cp -a -- "$source" "$HOME/.config/"
done
[[ ! -e $HOME/.bashrc ]] || cp -a -- "$HOME/.bashrc" "$backup/bashrc"
if ! grep -qF '/usr/share/omarchy/default/bash/rc' "$HOME/.bashrc" 2>/dev/null; then
  cat >> "$HOME/.bashrc" <<'EOF'

# Omadora desktop shell defaults
source /usr/share/omarchy/default/bash/env-bootstrap
[[ $- != *i* ]] || source /usr/share/omarchy/default/bash/rc
EOF
fi
cp -a --update=none -- "$OMARCHY_PATH/applications/." "$HOME/.local/share/applications/"
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Videos/Screencasts" "$HOME/.config/omarchy/themes"
if [[ $force == true || ! -f $HOME/.local/state/omarchy/current/theme.name ]]; then
  OMARCHY_THEME_HEADLESS=1 omarchy-theme-set 'Tokyo Night'
fi
if command -v google-chrome-stable >/dev/null; then
  xdg-settings set default-web-browser google-chrome.desktop || echo "Could not set default browser; desktop settings were preserved." >&2
elif command -v chromium >/dev/null; then
  xdg-settings set default-web-browser chromium.desktop || echo "Could not set default browser; desktop settings were preserved." >&2
fi
update-desktop-database "$HOME/.local/share/applications"
touch "$HOME/.local/state/omarchy/fedora-user-ready"
printf 'Existing configuration backed up to %s\n' "$backup"
