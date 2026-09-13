#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
top="$root/build"
mkdir -p "$top"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
tar --exclude=.git --exclude=build --exclude=docs/fedora-package-catalog.json \
  --transform='s,^,omarchedora-0.1.0/,' -czf "$top/SOURCES/omarchedora-0.1.0.tar.gz" -C "$root" .
awk '
  /@FEDORA_REQUIRES@/ {
    while ((getline package < "install/fedora/required.packages") > 0)
      if (package !~ /^#/ && package != "") print "Requires: " package
    next
  }
  { print }
' "$root/packaging/omarchedora.spec.in" > "$top/SPECS/omarchedora.spec"
rpmbuild --define "_topdir $top" -bb "$top/SPECS/omarchedora.spec"
