#!/bin/bash
set -euo pipefail
source /etc/os-release
[[ $ID == "fedora" && $VERSION_ID == "44" && $(uname -m) == "x86_64" ]] || {
  echo 'This installer targets Fedora 44 x86_64.' >&2
  exit 1
}
# The official RPM installs the Google Chrome repository for future DNF updates.
sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
