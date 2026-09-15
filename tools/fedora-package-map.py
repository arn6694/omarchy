"""Build a reviewable RPM map from the downloaded repository catalog."""
import json
import re
import shlex
from pathlib import Path

root = Path(__file__).resolve().parents[1]
catalog = json.loads((root / "docs/fedora-package-catalog.json").read_text())
packages = catalog["packages"]
renamed = {
    "bluez-utils": "bluez", "docker": "moby-engine docker-cli", "fd": "fd-find",
    "ufw": "firewalld", "openssh": "openssh-clients openssh-server",
    "vim": "vim-enhanced", "openbsd-netcat": "nmap-ncat",
    "python-gpgme": "python3-gpg", "python-protobuf": "python3-protobuf",
    "php-sqlite": "php-pdo", "xdebug": "php-pecl-xdebug3",
    "retroarch-assets-glui": "retroarch-assets", "retroarch-assets-ozone": "retroarch-assets",
    "retroarch-assets-xmb": "retroarch-assets", "libretro-database-git": "retroarch-database",
    "lua51": "compat-lua", "sof-firmware": "alsa-sof-firmware",
    "vpl-gpu-rt": "intel-vpl-gpu-rt", "broadcom-wl-dkms": "akmod-wl",
    "nvidia-dkms": "akmod-nvidia", "nvidia-open-dkms": "akmod-nvidia-open",
    "nvidia-580xx-dkms": "akmod-nvidia-580xx",
    "nvidia-utils": "xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda",
    "nvidia-580xx-utils": "xorg-x11-drv-nvidia-580xx xorg-x11-drv-nvidia-580xx-cuda",
    "imagemagick": "ImageMagick", "networkmanager": "NetworkManager",
    "libvips": "vips", "libreoffice-fresh": "libreoffice", "nvim": "neovim",
    "mariadb-libs": "mariadb-connector-c", "postgresql-libs": "libpq",
    "noto-fonts": "google-noto-sans-fonts google-noto-serif-fonts google-noto-sans-mono-fonts",
    "noto-fonts-cjk": "google-noto-sans-cjk-fonts",
    "noto-fonts-emoji": "google-noto-color-emoji-fonts",
    "python-gobject": "python3-gobject", "python-poetry-core": "python3-poetry-core",
    "qemu-user-static-binfmt": "qemu-user-static",
    "qt6-imageformats": "qt6-qtimageformats", "qt6-multimedia": "qt6-qtmultimedia",
    "qt6-multimedia-ffmpeg": "qt6-qtmultimedia", "qt6-wayland": "qt6-qtwayland",
    "tesseract-data-eng": "tesseract-langpack-eng", "vi": "vim-minimal",
    "woff2-font-awesome": "fontawesome-fonts-web",
    "linux": "kernel", "linux-headers": "kernel-devel kernel-headers",
    "libpulse": "pulseaudio-libs", "gst-plugin-pipewire": "pipewire-gstreamer",
    "pipewire-pulse": "pipewire-pulseaudio", "pipewire-jack": "pipewire-jack-audio-connection-kit",
    "vulkan-intel": "mesa-vulkan-drivers", "vulkan-radeon": "mesa-vulkan-drivers",
    "vulkan-asahi": "mesa-vulkan-drivers",
}
out = root / "install/fedora"
out.mkdir(exist_ok=True)
rows = []
evidence = {}
for group in ("base", "other"):
    selected = set()
    for line in (root / f"install/omarchy-{group}.packages").read_text().splitlines():
        source = line.strip()
        if not source or source.startswith("#"):
            continue
        targets = renamed.get(source, source).split()
        if all(target in packages for target in targets):
            rows.append((source, " ".join(targets), "verified", group))
            selected.update(targets)
            for target in targets:
                evidence[target] = packages[target]
        else:
            rows.append((source, "-", "omitted: no verified RPM in selected repositories", group))
    if group == "base":
        for target in "bash coreutils curl findutils gawk sed tar gzip util-linux procps-ng rpm dnf5 dnf5-plugins authselect firewalld pipewire pipewire-alsa pipewire-pulseaudio wireplumber polkit qt6-qtdeclarative libxkbcommon-utils lua xdg-user-dirs desktop-file-utils mesa-dri-drivers mesa-vulkan-drivers jetbrains-mono-fonts-all".split():
            assert target in packages, target
            selected.add(target)
            evidence[target] = packages[target]
    (out / f"{group}.packages").write_text("\n".join(sorted(selected)) + "\n", encoding="utf-8")
optional = set()
for path in (root / "bin").glob("omarchy-*"):
    text = path.read_text(encoding="utf-8").replace("\\\n", " ")
    for line in text.splitlines():
        if line.lstrip().startswith("#"):
            continue
        match = re.search(r'\bomarchy-pkg-(?:add|repo-add)\s+([^;&|<>]+)', line)
        if not match:
            continue
        try:
            tokens = shlex.split(match.group(1))
        except ValueError:
            continue
        optional.update(token for token in tokens if re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9+_.-]*', token))
menu = (root / "default/omarchy/omarchy-menu.jsonc").read_text(encoding="utf-8")
optional.update(re.findall(r'omarchy-pkg-present ([a-zA-Z0-9][a-zA-Z0-9+_.-]*)', menu))
optional.update(re.findall(r'\bttf-[a-z0-9-]+', menu))
seen = {row[0] for row in rows}
for source in sorted(optional - seen):
    targets = renamed.get(source, source).split()
    if all(target in packages for target in targets):
        rows.append((source, " ".join(targets), "verified", "optional"))
        for target in targets:
            evidence[target] = packages[target]
    else:
        rows.append((source, "-", "omitted: no verified RPM in selected repositories", "optional"))
(out / "package-map.tsv").write_text("# upstream\trpm\tstatus\tgroup\n" + "".join("\t".join(row) + "\n" for row in rows), encoding="utf-8")
(root / "docs/fedora-package-evidence.json").write_text(json.dumps({"sources": catalog["sources"], "packages": evidence}, indent=2) + "\n", encoding="utf-8")
report = ["# Fedora 44 package mapping", "", "Repository metadata was checked on 2026-09-13 for x86_64/noarch. A matching name is evidence of packaging, not proof of runtime compatibility. Unverified packages are omitted, not silently replaced by a different application. Additional repositories may resolve some omissions after review.", "", "| Upstream package | Fedora RPM(s) | Status | Group |", "|---|---|---|---|"]
report.extend("| " + " | ".join(row) + " |" for row in rows)
(root / "docs/fedora-package-map.md").write_text("\n".join(report) + "\n", encoding="utf-8")
print(f"{sum(row[2] == 'verified' for row in rows)} mapped; {sum(row[1] == '-' for row in rows)} omitted pending review")
