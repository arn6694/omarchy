"""Record package names and versions from Fedora 44 repository metadata."""
import gzip
import hashlib
import io
import json
import lzma
from pathlib import Path
import urllib.request
import xml.etree.ElementTree as ET

REPOS = {
    "fedora": "https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/",
    "updates": "https://dl.fedoraproject.org/pub/fedora/linux/updates/44/Everything/x86_64/",
    "hyprland-copr": "https://copr-be.cloud.fedoraproject.org/results/nett00n/hyprland/fedora-44-x86_64/",
    "rpmfusion-free": "https://download1.rpmfusion.org/free/fedora/releases/44/Everything/x86_64/os/",
    "rpmfusion-free-updates": "https://download1.rpmfusion.org/free/fedora/updates/44/x86_64/",
    "rpmfusion-nonfree": "https://download1.rpmfusion.org/nonfree/fedora/releases/44/Everything/x86_64/os/",
    "rpmfusion-nonfree-updates": "https://download1.rpmfusion.org/nonfree/fedora/updates/44/x86_64/",
}
NS = {"r": "http://linux.duke.edu/metadata/repo", "p": "http://linux.duke.edu/metadata/common"}
catalog = {}
def fetch(url):
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=120) as response:
                return response.read()
        except Exception:
            if attempt == 2:
                raise

for repo, base in REPOS.items():
    print(f"Reading {repo}", flush=True)
    root = ET.fromstring(fetch(base + "repodata/repomd.xml"))
    primary = root.find("r:data[@type='primary']", NS)
    location = primary.find("r:location", NS).attrib["href"]
    data = fetch(base + location)
    checksum = primary.find("r:checksum", NS)
    assert hashlib.new(checksum.attrib["type"], data).hexdigest() == checksum.text
    if location.endswith(".gz"):
        data = gzip.decompress(data)
    elif location.endswith(".xz"):
        data = lzma.decompress(data)
    elif location.endswith(".zst"):
        import zstandard
        data = zstandard.ZstdDecompressor().stream_reader(io.BytesIO(data)).read()
    for _, element in ET.iterparse(io.BytesIO(data), events=("end",)):
        if element.tag != "{" + NS["p"] + "}package":
            continue
        name = element.find("p:name", NS).text
        arch = element.find("p:arch", NS).text
        version = element.find("p:version", NS).attrib
        if arch in ("x86_64", "noarch"):
            catalog.setdefault(name, []).append({"repo": repo, "arch": arch, **version})
        element.clear()
    print(f"{len(catalog)} package names recorded", flush=True)
out = Path(__file__).resolve().parents[1] / "docs/fedora-package-catalog.json"
out.write_text(json.dumps({"sources": REPOS, "packages": catalog}, indent=2) + "\n", encoding="utf-8")
