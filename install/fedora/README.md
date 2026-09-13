# Fedora Server 44 port

Target: x86_64 Fedora Server 44 on the user's separate NVMe drive. Development host hardware: AMD Ryzen 7 4700G, AMD Radeon integrated graphics, NVIDIA GeForce RTX 3050.

The desktop retains upstream command names and configuration paths for hotkey and theme compatibility. The product name is Omarchedora. The upstream `SUPER + K` cheat sheet and all other key assignments are preserved.

`base.packages` contains verified Fedora, RPM Fusion, and selected COPR RPM names. `other.packages` is an inventory of optional/hardware equivalents, not an instruction to install every driver. `package-map.tsv` links upstream package requests to Fedora names and explicitly rejects omitted packages.

Hyprland and Quickshell come from the `nett00n/hyprland` COPR because this upstream branch uses Hyprland Lua configuration and Quickshell Networking. The downloaded Fedora 44 metadata includes Hyprland 0.56.2 and Quickshell 0.3.1. Repository metadata evidence is recorded in `docs/fedora-package-evidence.json`; desktop compatibility still needs a Fedora boot test.

Upstream disk provisioning, old migrations, bootloader replacement, and factory reset are not an installation path for this port. Fedora owns its kernel, bootloader, initramfs, SELinux policy, and base authentication policy.
