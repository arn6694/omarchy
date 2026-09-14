#!/bin/bash
# Apply the optional Omadora workstation profile to the current desktop user.
set -euo pipefail
(( EUID != 0 )) || { echo 'Run as the desktop user, not root.' >&2; exit 1; }
profile=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/workstation" && pwd)
[[ -f $HOME/.config/hypr/hyprland.lua ]] || { echo 'Run Fedora user setup first.' >&2; exit 1; }
for command in python3 omarchy-plugin-clone omarchy-plugin-enable omarchy-font-set hyprctl omarchy-restart-shell omarchy-hyprland-session-locked; do
  command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
lock_status=0
omarchy-hyprland-session-locked || lock_status=$?
[[ $lock_status == 1 ]] || { echo 'Unlock the desktop and confirm Hyprland is running before applying the profile.' >&2; exit 1; }
backup="$HOME/.local/state/omarchy/backups/$(date +%Y%m%d-%H%M%S)-workstation-$$"
mkdir -p "$backup" "$HOME/.config/hypr" "$HOME/.local/bin"
for entry in .config/hypr .config/nvim .config/omarchy .config/xdg-terminals.list .wezterm.lua; do
  if [[ -e $HOME/$entry ]]; then
    mkdir -p "$backup/$(dirname "$entry")"
    cp -a "$HOME/$entry" "$backup/$entry"
  fi
done
export OMADORA_PROFILE="$profile"
python3 - <<'PY'
from pathlib import Path
import os,shutil
home=Path.home(); profile=Path(os.environ['OMADORA_PROFILE']); hypr=home/'.config/hypr'
config=hypr/'hyprland.lua'
s=config.read_text()
marker='-- Omadora workstation profile\n'
if marker not in s:
    if 'require("default.hypr.omarchy")' not in s:
        raise SystemExit('Expected default.hypr.omarchy import was not found; configuration unchanged.')
    s=s.replace('require("default.hypr.omarchy")', marker+'omarchy_preinstalled_bindings = false\nrequire("hypr.equal-layout")\nrequire("default.hypr.omarchy")')
    s+='\nrequire("hypr.omadora-bindings")\nhl.config({ general = { layout = "lua:omadora-equal" } })\n'
config.write_text(s)
for source,target in [('equal-layout.lua','equal-layout.lua'),('bindings.lua','omadora-bindings.lua')]:
    shutil.copy2(profile/source,hypr/target)
shutil.copy2(profile/'wezterm.lua',home/'.wezterm.lua')
shutil.copytree(profile/'nvim',home/'.config/nvim',dirs_exist_ok=True)
# Theme renderer may replace this file later; maintain the upstream theme hook.
(home/'.config/xdg-terminals.list').write_text('org.wezfurlong.wezterm.desktop\nfoot.desktop\n')
PY
install -m755 "$profile/uwsm-app" "$HOME/.local/bin/uwsm-app"
# The user clone inherits the installed lock service; only its view is changed.
clone="${USER:-$(id -un)}.lock"
clone_dir="$HOME/.config/omarchy/plugins/$clone"
if [[ ! -d $clone_dir ]]; then
  omarchy-plugin-clone omarchy.lock
fi
install -m644 "$profile/lock/LockView.qml" "$profile/lock/wallpaper.png" "$clone_dir/"
omarchy-plugin-enable "$clone"
omarchy-font-set 'JetBrainsMono Nerd Font'
hyprctl reload
omarchy-restart-shell
printf 'Workstation profile applied. Backup: %s\n' "$backup"
