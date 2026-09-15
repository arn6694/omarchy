#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export FEDORA_TEST_LOG="$scratch/log" FEDORA_TEST_DB="$scratch/packages"
printf 'installed\n' > "$FEDORA_TEST_DB"
cat > "$scratch/bin/rpm" <<'SH'
#!/bin/bash
if [[ $1 == "-qa" ]]; then
  cat "$FEDORA_TEST_DB"
else
  grep -Fxq -- "${@: -1}" "$FEDORA_TEST_DB"
fi
SH
cat > "$scratch/bin/dnf" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$FEDORA_TEST_LOG"
[[ ${FEDORA_TEST_FAIL:-0} == 0 ]] || exit 42
action=$2
shift 3
if [[ $action == "install" ]]; then
  printf '%s\n' "$@" >> "$FEDORA_TEST_DB"
fi
SH
cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT"

omarchy-pkg-add installed
[[ ! -e $FEDORA_TEST_LOG ]] || fail "already installed packages must not trigger a transaction"
omarchy-pkg-add installed missing
grep -Fxq -- '-y install -- installed missing' "$FEDORA_TEST_LOG" || fail "mixed package installation"
omarchy-pkg-present installed missing || fail "installed checks use RPM"
if omarchy-pkg-missing installed missing; then fail "all packages are present"; fi
if omarchy-pkg-add --allowerasing >/dev/null 2>&1; then fail "reject DNF options as package names"; fi
if FEDORA_TEST_FAIL=1 omarchy-pkg-add failure >/dev/null 2>&1; then fail "propagate transaction failure"; fi
omarchy-pkg-drop installed installed nonexistent
grep -Fxq -- '-y remove -- installed' "$FEDORA_TEST_LOG" || fail "remove only installed packages once"
omarchy-pkg-add nvim
grep -Fxq -- '-y install -- neovim' "$FEDORA_TEST_LOG" || fail "translate upstream package names"
omarchy-pkg-present nvim || fail "presence checks share the package mapping"
omarchy-pkg-drop nvim
grep -Fxq -- '-y remove -- neovim' "$FEDORA_TEST_LOG" || fail "removal shares the package mapping"
if omarchy-pkg-add aether >/dev/null 2>&1; then fail "omitted package must fail explicitly"; fi
omarchy-pkg-present || fail "empty presence query is true"
if omarchy-pkg-missing; then fail "empty missing query is false"; fi
pass "Fedora RPM checks and DNF transactions"
