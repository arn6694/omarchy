from pathlib import Path
import tempfile,subprocess,os
repo=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as d:
    home=Path(d); mock=home/'mock';mock.mkdir()
    hypr=home/'.config/hypr';hypr.mkdir(parents=True)
    (hypr/'hyprland.lua').write_text('require("default.hypr.omarchy")\n')
    for name in ['omarchy-plugin-enable','omarchy-font-set','hyprctl','omarchy-restart-shell','update-desktop-database']:
        p=mock/name;p.write_text('#!/bin/bash\nexit 0\n');p.chmod(0o755)
    p=mock/'omarchy-hyprland-session-locked';p.write_text('#!/bin/bash\nexit "${TEST_LOCKED:-1}"\n');p.chmod(0o755)
    p=mock/'omarchy-plugin-clone';p.write_text('#!/bin/bash\nmkdir -p "$HOME/.config/omarchy/plugins/$USER.lock"\nprintf "id: idleBlankTimer\\n    interval: 5000\\n" > "$HOME/.config/omarchy/plugins/$USER.lock/Service.qml"\n');p.chmod(0o755)
    env=dict(os.environ,HOME=d,PATH=str(mock)+':'+os.environ['PATH'])
    layouts=home/'.local/state/omarchy/workspace-layouts'
    layouts.mkdir(parents=True)
    (layouts/'1.lua').write_text('scrolling override')
    script=repo/'install/fedora/apply-workstation.sh'
    for _ in range(2): subprocess.run(['bash',str(script)],env=env,check=True,stdout=subprocess.DEVNULL)
    s=(hypr/'hyprland.lua').read_text()
    assert s.count('require("hypr.omadora-bindings")')==1
    assert 'lua:omadora-equal' in s
    assert not (layouts/'1.lua').exists()
    assert any(p.read_text()=='scrolling override' for p in (home/'.local/state/omarchy/backups').glob('*/.local/state/omarchy/workspace-layouts/1.lua'))
    assert (home/'.config/nvim/lazy-lock.json').exists()
    assert len(list((home/'.local/state/omarchy/backups').iterdir()))==2
    result=subprocess.run(['bash',str(script)],env=dict(env,TEST_LOCKED='0'),capture_output=True)
    assert result.returncode!=0 and b'Unlock' in result.stderr
    assert (hypr/'hyprland.lua').read_text()==s
    executable=home/'app with spaces';executable.write_text('#!/bin/bash\nprintf "%s\\n" "$@"\n');executable.chmod(0o755)
    subprocess.run(['bash',str(repo/'install/fedora/register-desktop.sh'),'chatgpt',str(executable)],env=env,check=True,stdout=subprocess.DEVNULL)
    args=subprocess.check_output([str(home/'.local/bin/chatgpt'),'argument with spaces'],env=env,text=True)
    assert args.splitlines()==['--ozone-platform=wayland','argument with spaces']
print('PASS: profile applies twice, backs up, blocks while locked, and launchers preserve arguments')
