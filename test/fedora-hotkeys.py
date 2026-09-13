"""Verify the full upstream hotkey configuration and cheat sheet are preserved."""
import hashlib
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[1]
upstream = "b679363bed05415771a1b1dc92c6899a908236f7"
files = [*sorted((root / "default/hypr/bindings").glob("*.lua")), root / "config/hypr/bindings.lua", root / "bin/omarchy-menu-keybindings"]
for file in files:
    name = file.relative_to(root).as_posix()
    original = subprocess.check_output(["git", "show", f"{upstream}:{name}"], cwd=root)
    current = file.read_bytes().replace(b"\r\n", b"\n")
    assert hashlib.sha256(original.replace(b"\r\n", b"\n")).digest() == hashlib.sha256(current).digest(), name
assert 'o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings")' in (root / "default/hypr/bindings/utilities.lua").read_text()
print(f"PASS: {len(files)} upstream keybinding/cheat-sheet files unchanged; Super+K preserved")
