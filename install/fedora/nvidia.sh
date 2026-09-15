#!/bin/bash
set -euo pipefail
source /etc/os-release
[[ $ID == "fedora" && $VERSION_ID == "44" ]] || { echo 'Fedora 44 required.' >&2; exit 1; }
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda kernel-devel-matched mokutil
sudo akmods --force
sudo dracut --regenerate-all --force
if mokutil --sb-state | grep -qi 'enabled'; then
  echo 'Secure Boot is enabled. Complete RPM Fusion signing-key enrollment before booting the NVIDIA driver.'
  echo 'See https://rpmfusion.org/Howto/Secure%20Boot'
fi
echo 'NVIDIA packages installed. Reboot after reviewing any signing-key enrollment requirements.'
