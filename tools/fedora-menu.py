"""Hide install entries for explicitly omitted packages, preserving hotkeys."""
import json
from pathlib import Path
import re
import shlex

root = Path(__file__).resolve().parents[1]
mapping = {}
for line in (root / "install/fedora/package-map.tsv").read_text().splitlines():
    if line and not line.startswith("#"):
        source, target, *_ = line.split("\t")
        mapping[source] = target
path = root / "default/omarchy/omarchy-menu.jsonc"
lines = []
omitted = []
for line in path.read_text(encoding="utf-8").splitlines():
    match = re.match(r'^(\s*)("install\.[^"]+"):\s*(\{.*\})(,?)$', line)
    if match:
        entry = json.loads(match[3])
        names = re.findall(r'omarchy-pkg-present ([a-zA-Z0-9][a-zA-Z0-9+_.-]*)', entry.get("disabled", ""))
        action = entry.get("action", "")
        names += re.findall(r'\bttf-[a-z0-9-]+', action)
        # Named app installers have fixed dependency sets. Parameterized
        # installers are checked by their package guard above.
        try:
            tokens = shlex.split(action)
            candidates = []
            for token in tokens:
                inner = shlex.split(token)
                if len(inner) == 1 and inner[0].startswith("omarchy-install-"):
                    candidates.append(inner[0])
            for command in candidates:
                source = root / "bin" / command
                if not source.is_file():
                    continue
                body = source.read_text(encoding="utf-8").replace("\\\n", " ")
                for dependency in re.findall(r'omarchy-pkg-(?:add|repo-add)\s+([^\n;&|<>]+)', body):
                    try:
                        names += [x for x in shlex.split(dependency) if re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9+_.-]*', x)]
                    except ValueError:
                        pass
        except ValueError:
            pass
        missing = sorted({name for name in names if mapping.get(name) == "-"})
        if missing:
            entry["when"] = "false"
            omitted.append((json.loads(match[2]), entry.get("label", ""), ", ".join(missing)))
            line = match[1] + match[2] + ": " + json.dumps(entry, ensure_ascii=False, separators=(",", ":")) + match[4]
    lines.append(line)
path.write_text("\n".join(lines) + "\n", encoding="utf-8")
report = ["# Omitted install menu entries", "", "These entries are hidden because their requested package set contains an unverified RPM. Their original key assignments are not changed. This report also lists missing dependencies for review.", "", "| Menu ID | Label | Missing dependencies |", "|---|---|---|"]
report += ["| " + " | ".join(row) + " |" for row in omitted]
(root / "docs/fedora-omitted-menu.md").write_text("\n".join(report) + "\n", encoding="utf-8")
print(f"{len(omitted)} unsupported install entries hidden")
