# Omarchedora build status

## Target and provenance

- Fedora Server 44, x86_64, installed on a separate NVMe drive.
- Development target hardware: Ryzen 7 4700G, AMD Radeon integrated graphics, GeForce RTX 3050.
- Upstream: `https://github.com/omacom/omarchy`, branch `quattro`, commit `b679363bed05415771a1b1dc92c6899a908236f7`.
- Intended GitHub owner: `arn9999`. Remote fork creation and push are pending GitHub authentication.

## Implemented locally

- DNF/RPM package installation, removal, queries, menus, update operations, and explicit mapping of old package names.
- Fedora Server installer with a read-only package-availability check and a separate install mode.
- RPM packaging and a Fedora 44 GitHub Actions build workflow.
- Fedora authentication integration using system-auth/authselect, dracut integration, and an optional RPM Fusion NVIDIA setup command.
- A separate Fedora migration namespace; upstream installation, recovery, and migration trees are excluded from the RPM.
- Exact preservation of the eight upstream keybinding and cheat-sheet files, including Super+K/Command+K.
- Repository metadata evidence, default/optional package mappings, and omitted-feature/install-menu reports.

## Validation still required before release

Local checks completed: DNF/RPM helper behavior, renamed-package installation/removal, explicit rejection of omitted packages, all runtime Bash syntax, targeted installer/firewall syntax, menu parsing (340 entries), runtime isolation assertions, exact comparison of eight hotkey/cheat-sheet files, and Git whitespace checks. The upstream CLI suite completed 38 assertions, then stopped with exit 49 at the Windows `python3` app-execution alias. It is not a passing full CLI run; the Fedora CI job must complete it.

1. Run the Fedora 44 workflow and resolve any RPM build errors. The RPM has not been built on this Windows development host.
2. Run a real DNF transaction in a disposable Fedora 44 environment. Metadata availability is not a dependency-solver or install test.
3. Boot a Fedora VM and verify Hyprland Lua configuration, Quickshell modules, login, authentication, networking, audio, themes, and Super+K interaction. Static preservation does not establish working desktop behavior.
4. Validate NVIDIA driver loading and signing-key enrollment on the target PC. No disk, firmware, Windows installation, or installed GPU driver was changed during development.
5. Review omitted packages and features, including Nerd Font coverage, upstream custom applications, automatic hibernation setup, and bootable snapshot recovery. Some have not been found in the selected repositories; this does not establish that no third-party Fedora package exists elsewhere.
6. Audit optional integrations beyond package names. Upstream vendor installers, application file locations, and hardware-specific behavior can still need Fedora adaptation.

This is an experimental source port, not a release-ready image or a tested Fedora installation. The retained upstream manual and legacy setup directories are reference material; the Fedora installation entry point is `install.sh`.

The default application set is installed alongside the Omarchedora RPM. Only core desktop/runtime requirements are RPM dependencies, so removing an optional application does not inherently require removing the desktop package.
