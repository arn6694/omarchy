# Features omitted from the Fedora port

- `omarchy-channel-set`: Upstream release channels are not Fedora repositories. This build uses Fedora 44.
- `omarchy-system-factory-reset`: The upstream factory-reset disk layout has no verified Fedora equivalent. Reinstall using Fedora media.
- `omarchy-provision-owner`: Deferred ISO owner provisioning is not included. Create the user in Fedora Server's installer.
- `omarchy-upgrade-to-quattro`: Cross-distribution upgrades are not supported. Install Omadora onto an existing Fedora Server 44 system.
- `omarchy-dev-pkg-test`: The upstream package-builder environment is not included in the Fedora port.
- `omarchy-hibernation-setup`: Automatic hibernation provisioning is omitted pending a Fedora swap and encryption configuration review.
- `omarchy-hibernation-remove`: Automatic hibernation configuration removal is omitted; Fedora owns the swap and resume configuration.

These entries are explicit limitations, not completed feature ports. Package omissions are listed separately in [fedora-package-map.md](fedora-package-map.md).

- `omarchy-snapshot restore`: automatic boot-menu rollback is omitted. Snapshot creation works only with an administrator-configured Snapper filesystem; it does not establish bootable recovery.
- Upstream custom Emacs/Neovim configuration packages, several applications, and Nerd Font packages are not available in the selected repository inventory. Fedora Emacs and Neovim packages are used; missing customization is not claimed as equivalent.
- Fedora firewalld owns firewall management. The SSH setup command enables the SSH service; it does not recreate UFW's connection-rate-limit implementation.
- The original factory-reset completion worker, legacy installer/hardware setup, bootloader templates, package hooks, and upstream migrations are excluded from the Fedora RPM.
