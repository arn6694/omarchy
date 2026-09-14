# Omarchedora build status

## Target and provenance

- Fedora Server 44, x86_64, installed on a separate NVMe drive.
- Development target hardware: Ryzen 7 4700G, AMD Radeon integrated graphics, GeForce RTX 3050.
- Upstream: `https://github.com/omacom/omarchy`, branch `quattro`, commit `b679363bed05415771a1b1dc92c6899a908236f7`.
- GitHub fork: `arn6694/omarchy`; Fedora branch: `codex/fedora-port`.

## Implemented on the Fedora branch

- DNF/RPM package installation, removal, queries, menus, update operations, and explicit mapping of old package names.
- Fedora Server installer with a read-only package-availability check and a separate install mode.
- RPM packaging and a Fedora 44 GitHub Actions build workflow.
- Fedora authentication integration using system-auth/authselect, dracut integration, and an optional RPM Fusion NVIDIA setup command.
- A separate Fedora migration namespace; upstream installation, recovery, and migration trees are excluded from the RPM.
- Exact preservation of the eight upstream keybinding and cheat-sheet files, including Super+K/Command+K.
- Repository metadata evidence, default/optional package mappings, and omitted-feature/install-menu reports.

## Validation still required before release

Checks completed on Fedora 44 in GitHub Actions: the full upstream CLI suite, DNF/RPM helper tests, runtime Bash syntax, runtime isolation assertions, exact comparison of eight hotkey/cheat-sheet files, and RPM construction. Local checks also covered menu parsing (340 entries) and Git whitespace. The Linux CLI run supersedes the earlier partial Windows run.

1. Keep the Fedora 44 workflow passing as the port develops. RPM construction and CLI regression checks now pass on Fedora.
2. The real DNF installation of the RPM and default packages passed in a disposable Fedora 44 container, followed by installed command-metadata validation. [Passing CI run and RPM artifact](https://github.com/arn6694/omarchy/actions/runs/34795313378), tested code commit `9c3b2221930f27610dca209f60cdded6356f6c26`. This validates dependency resolution and package installation, not system/user setup or graphical boot.
3. Boot a Fedora VM and verify Hyprland Lua configuration, Quickshell modules, login, authentication, networking, audio, themes, and Super+K interaction. Static preservation does not establish working desktop behavior.
4. Validate NVIDIA driver loading and signing-key enrollment on the target PC. No disk, firmware, Windows installation, or installed GPU driver was changed during development.
5. Review omitted packages and features, including Nerd Font coverage, upstream custom applications, automatic hibernation setup, and bootable snapshot recovery. Some have not been found in the selected repositories; this does not establish that no third-party Fedora package exists elsewhere.
6. Audit optional integrations beyond package names. Upstream vendor installers, application file locations, and hardware-specific behavior can still need Fedora adaptation.

This is an experimental source port, not a release-ready image or a tested Fedora installation. The retained upstream manual and legacy setup directories are reference material; the Fedora installation entry point is `install.sh`.

The default application set is installed alongside the Omarchedora RPM. Only core desktop/runtime requirements are RPM dependencies, so removing an optional application does not inherently require removing the desktop package.
