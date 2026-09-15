"""Check that the Fedora runtime cannot fall back to Arch package operations."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
for path in (root / "bin").glob("*"):
    if not path.is_file():
        continue
    text = path.read_text(encoding="utf-8")
    assert not re.search(r'\b(?:pacman|yay|mkinitcpio|limine)\b', text), path.name
assert 'system-local-login' not in (root / 'bin/omarchy-apply-lock').read_text()
assert 'system-auth' in (root / 'bin/omarchy-apply-lock').read_text()
assert 'MIGRATIONS_DIR="$OMARCHY_PATH/install/fedora/migrations"' in (root / 'bin/omarchy-migrate').read_text()
spec = (root / 'packaging/omarchedora.spec.in').read_text()
assert 'cp -a install/fedora install/helpers ' in spec
for removed in ('default/pacman', 'default/libalpm', 'default/limine', 'bin/omarchy-system-factory-reset-finish'):
    assert re.search(r'rm -[rf]+ .*' + re.escape(removed), spec), removed
print('PASS: Fedora runtime and package isolation invariants')
