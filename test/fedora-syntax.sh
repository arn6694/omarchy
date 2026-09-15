#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
failed=0
while IFS= read -r -d '' file; do
  IFS= read -r first_line < "$file" || true
  if [[ $first_line == '#!/bin/bash'* ]]; then
    bash -n "$file" || failed=1
  fi
done < <(find "$root/bin" "$root/install/fedora" -type f -print0)
bash -n "$root/install.sh" || failed=1
bash -n "$root/packaging/build-rpm.sh" || failed=1
(( failed != 0 )) || echo 'PASS: Fedora runtime shell syntax'
exit "$failed"
