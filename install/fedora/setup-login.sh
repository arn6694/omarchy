#!/bin/bash
set -euo pipefail
(( EUID == 0 )) || exit 1
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
backup="/var/lib/omadora/login-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for entry in /etc/sddm.conf.d/90-omadora.conf /var/lib/sddm/state.conf /usr/share/sddm/themes/omadora /usr/share/omarchy/install/fedora/setup-user.sh /usr/share/omarchy/bin/omarchy-provision-user /usr/share/omarchy/bin/omarchy-reinstall-configs; do
  if [[ -e $entry ]]; then cp -a --parents "$entry" "$backup/"; fi
done
dnf -y --setopt=install_weak_deps=False install sddm-themes xorg-x11-server-Xorg xorg-x11-drv-libinput
if rpm -q sddm-wayland-generic >/dev/null 2>&1; then
  dnf -y --setopt=clean_requirements_on_remove=False --setopt=install_weak_deps=False swap sddm-wayland-generic sddm-x11
else
  dnf -y --setopt=install_weak_deps=False install sddm-x11
fi
mkdir -p /etc/sddm.conf.d /usr/share/sddm/themes/omadora
cp -a "$root/install/fedora/workstation/login/." /usr/share/sddm/themes/omadora/
install -m644 "$root/install/fedora/workstation/lock/wallpaper.png" /usr/share/sddm/themes/omadora/omadora-wallpaper.png
cat > /etc/sddm.conf.d/90-omadora.conf <<'CONF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=omadora
CursorTheme=Adwaita
[Users]
RememberLastUser=true
RememberLastSession=true
CONF
install -m755 "$root/install/fedora/setup-user.sh" /usr/share/omarchy/install/fedora/setup-user.sh
install -m755 "$root/bin/omarchy-provision-user" /usr/share/omarchy/bin/omarchy-provision-user
install -m755 "$root/bin/omarchy-reinstall-configs" /usr/share/omarchy/bin/omarchy-reinstall-configs
restorecon -RF /etc/sddm.conf.d /usr/share/sddm/themes/omadora /usr/share/omarchy/install/fedora/setup-user.sh
printf 'Login changes apply at next logout. Backups: %s\n' "$backup"
