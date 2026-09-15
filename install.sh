#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mode=${1:---check}
case "$mode" in
  --check|--install) ;;
  *) echo 'Usage: bash install.sh [--check|--install]' >&2; exit 2 ;;
esac
[[ -r /etc/os-release ]] || { echo 'Fedora Server 44 is required.' >&2; exit 1; }
source /etc/os-release
[[ $ID == "fedora" && $VERSION_ID == "44" && $(uname -m) == "x86_64" ]] || {
  echo 'This build targets Fedora Server 44 x86_64.' >&2; exit 1;
}
(( EUID != 0 )) || { echo 'Run as your desktop user, not root; sudo is requested when needed.' >&2; exit 1; }
if [[ $mode == "--install" ]]; then
  sudo dnf install dnf5-plugins rpm-build tar gzip
  sudo dnf install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm
  sudo dnf copr enable nett00n/hyprland
fi
command -v dnf >/dev/null
available=$(dnf -q repoquery --available --queryformat '%{name}\n')
missing=0
while IFS= read -r package; do
  [[ -n $package && $package != \#* ]] || continue
  if ! grep -Fxq -- "$package" <<< "$available"; then
    printf 'Unavailable RPM: %s\n' "$package" >&2
    missing=1
  fi
done < "$root/install/fedora/base.packages"
(( missing == 0 )) || { echo 'Enable the documented repositories and resolve unavailable RPMs before installation.' >&2; exit 1; }
echo 'Default RPM names are available. See docs/fedora-package-map.md for omitted upstream packages.'
[[ $mode == "--install" ]] || exit 0
bash "$root/packaging/build-rpm.sh"
mapfile -t rpms < <(find "$root/build/RPMS" -name 'omarchedora-*.noarch.rpm' -type f)
(( ${#rpms[@]} == 1 )) || { echo 'Expected exactly one built Omadora RPM.' >&2; exit 1; }
mapfile -t packages < <(grep -Ev '^(#|$)' "$root/install/fedora/base.packages")
sudo dnf install "${rpms[0]}" "${packages[@]}"
bash "$root/install/fedora/chrome.sh"
sudo bash /usr/share/omarchy/install/fedora/setup-system.sh
export OMARCHY_PATH=/usr/share/omarchy
export PATH="$OMARCHY_PATH/bin:$PATH"
bash "$OMARCHY_PATH/install/fedora/setup-user.sh"
echo 'Select Omadora at the login screen after rebooting.'
echo 'RTX 3050 users: run bash /usr/share/omarchy/install/fedora/nvidia.sh to install RPM Fusion drivers.'
