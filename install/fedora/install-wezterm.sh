#!/bin/bash
# Install an explicitly supplied official WezTerm AppImage without FUSE.
set -euo pipefail
(( EUID != 0 )) || { echo 'Run as the desktop user.' >&2; exit 1; }
[[ $# == 2 ]] || { echo 'Usage: install-wezterm.sh /path/to/WezTerm.AppImage expected-sha256' >&2; exit 2; }
artifact=$(realpath -- "$1")
[[ $2 =~ ^[[:xdigit:]]{64}$ ]] || { echo 'Expected SHA-256 is required.' >&2; exit 2; }
actual=$(sha256sum "$artifact"); actual=${actual%% *}
[[ ${actual,,} == ${2,,} ]] || { echo 'SHA-256 mismatch.' >&2; exit 1; }
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$HOME/.local/opt"
stage=$(mktemp -d "$HOME/.local/opt/.wezterm.XXXXXX")
trap 'rm -rf "$stage"' EXIT
cp "$artifact" "$stage/wezterm.AppImage"
chmod +x "$stage/wezterm.AppImage"
(cd "$stage" && ./wezterm.AppImage --appimage-extract >/dev/null)
[[ -x $stage/squashfs-root/AppRun ]] || exit 1
destination="$HOME/.local/opt/wezterm-${actual:0:12}"
[[ ! -e $destination ]] || { echo "Already installed: $destination"; bash "$root/register-desktop.sh" wezterm "$destination/squashfs-root/AppRun"; exit; }
mv "$stage" "$destination"
bash "$root/register-desktop.sh" wezterm "$destination/squashfs-root/AppRun"
