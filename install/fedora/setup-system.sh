#!/bin/bash
set -euo pipefail
(( EUID == 0 )) || { echo 'System setup requires root.' >&2; exit 1; }
source /etc/os-release
[[ $ID == "fedora" && $VERSION_ID == "44" ]] || { echo 'Fedora 44 required.' >&2; exit 1; }
export OMARCHY_PATH=/usr/share/omarchy
export PATH="$OMARCHY_PATH/bin:/usr/sbin:/usr/bin:/sbin:/bin"
omarchy-apply-lock
systemctl enable NetworkManager.service firewalld.service bluetooth.service power-profiles-daemon.service sddm.service
systemctl set-default graphical.target
restorecon -RF /usr/share/omarchy /etc/pam.d/omarchy-lock-password
echo 'Omadora session enabled. Log out or reboot when ready.'
