"""Keep changed source text LF-terminated when developing on Windows."""
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(['git', 'diff', '--name-only', '-z'], cwd=root).split(b'\0')
paths += subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=root).split(b'\0')
count = 0
for item in set(paths):
    if not item:
        continue
    path = root / item.decode('utf-8')
    if not path.is_file():
        continue
    data = path.read_bytes()
    if b'\0' in data:
        continue
    try:
        data.decode('utf-8')
    except UnicodeError:
        continue
    normalized = data.replace(b'\r\n', b'\n')
    if data != normalized:
        path.write_bytes(normalized)
        count += 1
print(f'Normalized {count} changed text files to LF')
