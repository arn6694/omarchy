from pathlib import Path
import tempfile,subprocess,os
repo=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as d:
 h=Path(d);root=h/'source';(root/'config/hypr').mkdir(parents=True);(root/'config/hypr/hyprland.lua').write_text('DEFAULT')
 (root/'applications').mkdir();(h/'.config/hypr').mkdir(parents=True);cfg=h/'.config/hypr/hyprland.lua';cfg.write_text('CUSTOM')
 (h/'.local/state/omarchy/current').mkdir(parents=True);(h/'.local/state/omarchy/current/theme.name').write_text('CUSTOM THEME')
 m=h/'mock';m.mkdir()
 for name in ['xdg-user-dirs-update','update-desktop-database','google-chrome-stable']:
  p=m/name;p.write_text('#!/bin/bash\nexit 0\n');p.chmod(0o755)
 p=m/'xdg-settings';p.write_text('#!/bin/bash\nexit 1\n');p.chmod(0o755)
 env=dict(os.environ,HOME=str(h),OMARCHY_PATH=str(root),PATH=str(m)+':'+os.environ['PATH'])
 for _ in range(2):subprocess.run(['bash',str(repo/'install/fedora/setup-user.sh')],env=env,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 assert cfg.read_text()=='CUSTOM'
 assert (h/'.local/state/omarchy/fedora-user-ready').exists()
 assert (h/'.local/state/omarchy/current/theme.name').read_text()=='CUSTOM THEME'
 print('PASS: existing settings and theme survive missing marker, browser failure, and repeated setup')
