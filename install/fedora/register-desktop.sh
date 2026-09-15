#!/bin/bash
# Register a separately installed native application; never copy account data.
set -euo pipefail
(( EUID != 0 )) || { echo 'Run as the desktop user.' >&2; exit 1; }
[[ $# == 2 ]] || { echo 'Usage: register-desktop.sh {chatgpt|claude-desktop|grok-bot|hermes-desktop|obsidian|wezterm} /absolute/path/to/executable' >&2; exit 2; }
app=$1
executable=$2
[[ $executable == /* && -x $executable && $executable != *$'\n'* ]] || { echo 'Supply an absolute executable path.' >&2; exit 2; }
case "$app" in
  chatgpt) name=ChatGPT; id=chatgpt ;;
  claude-desktop) name=Claude; id=claude-desktop ;;
  grok-bot) name='Grok Bot'; id=grok-bot ;;
  hermes-desktop) name=Hermes; id=hermes-desktop ;;
  obsidian) name=Obsidian; id=obsidian ;;
  wezterm) name=WezTerm; id=org.wezfurlong.wezterm ;;
  *) echo 'Unsupported application.' >&2; exit 2 ;;
esac
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
wrapper="$HOME/.local/bin/$app"
[[ $executable != "$wrapper" ]] || { echo 'Executable must not be the wrapper itself.' >&2; exit 2; }
[[ ! -e $wrapper ]] || cp -a "$wrapper" "$wrapper.before-omadora"
printf '#!/bin/bash\nexec %q ' "$executable" > "$wrapper"
if [[ $app != wezterm ]]; then printf '%s ' '--ozone-platform=wayland' >> "$wrapper"; fi
printf '"$@"\n' >> "$wrapper"
chmod 755 "$wrapper"
# Wrapper is addressed through PATH, avoiding Desktop Entry quoting of user paths.
{
  printf '[Desktop Entry]\nType=Application\nName=%s\n' "$name"
  if [[ $app == wezterm ]]; then
    printf 'Exec=wezterm start\nTryExec=wezterm\nCategories=System;TerminalEmulator;\nX-TerminalArgExec=--\nX-TerminalArgDir=--cwd\n'
  else
    printf 'Exec=%s %%U\nCategories=Office;\n' "$app"
  fi
  printf 'Icon=%s\nTerminal=false\n' "$id"
} > "$HOME/.local/share/applications/$id.desktop"
update-desktop-database "$HOME/.local/share/applications"
printf '%s registered. Account sign-in remains separate.\n' "$name"
