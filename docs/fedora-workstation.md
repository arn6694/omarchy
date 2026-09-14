# Omadora workstation profile

The optional profile captures the Fedora workstation customization completed September 14, 2026. It is separate from the minimal desktop install: it does not install alternate browsers, password managers, or the full upstream app collection.

## Apply on another machine

1. Install the Fedora port normally using `bash install.sh --install`. Chrome is included; Python XDG and Perl JSON runtime dependencies are now explicit, and the RPM provides the Fedora `uwsm-app` launcher compatibility wrapper.
2. Install the selected optional RPMs with `sudo dnf install steam curl tar xz google-noto-sans-fonts`. Steam needs RPM Fusion, enabled by the base installer.
3. Run `bash install/fedora/install-fonts.sh`. This installs JetBrains Mono, Fira Code, and Meslo Nerd Fonts from release v3.4.0 and selects JetBrains Mono for desktop icons.
4. Obtain an official WezTerm AppImage from https://wezterm.org/install/linux.html. The older stable build failed to display on the tested machine; its nightly build worked. Run `bash install/fedora/install-wezterm.sh /path/to/WezTerm.AppImage EXPECTED_SHA256`. Use a checksum verified against the vendor download. The script checks it before executing the AppImage and extracts it into a versioned user directory.
5. Install any desired native AI desktop apps and Obsidian separately from their trusted distributors, then register each using `bash install/fedora/register-desktop.sh APP /absolute/path/to/installed/executable`. Supported APP values: `chatgpt`, `claude-desktop`, `grok-bot`, `hermes-desktop`, `obsidian`, `wezterm`. This creates native launch wrappers and desktop entries; it does not download those proprietary applications or include account state. For WezTerm, step 4 already registers it.
6. From an unlocked, running Omadora desktop, run `bash install/fedora/apply-workstation.sh`. This backs up existing configuration, applies the shortcuts/layout, WezTerm and Neovim config, and clones the installed lock service with the personalized view. Existing extra Neovim files are retained. Open Neovim to let Lazy install its recorded plugins; network access is needed on first use.

The profile can be reapplied. It changes user preferences, including keyboard shortcuts and editor settings; use the printed backup directory to restore them. Run it after logging in, not during a headless install. The lock service and authentication implementation come from the installed Omarchy version; only the visual component is replaced. Do not restart the shell while locked.

## Shortcuts and layout

Super means Windows/Command. Super+Return opens WezTerm; Super+Shift+B opens Chrome; Super+Shift+F opens Files; Super+Shift+N opens Neovim. Super+Shift+A/C/G/H/O opens or focuses ChatGPT/Claude/Grok Bot/Hermes/Obsidian. Super+Shift+S opens Steam's library. Super+K shows the cheat sheet.

Equal tiling is the default: two equal columns, three equal columns, four quadrants, larger counts in equal grid cells with unused cells in incomplete rows. Floating dialogs retain their size. Super+L or Super+Ctrl+G selects and saves equal tiling; Super+Ctrl+Shift+L selects resizable dwindle tiling. Applying the profile backs up and clears old workspace layout overrides. Subsequent layout selections are saved per workspace. WezTerm's Fedora app ID is tagged as a terminal for correct copy/paste shortcuts.

The lock view uses the supplied 3840×2160 red-fedora wallpaper, an unblurred background, AM/PM clock on the left, and Omadora branding without a personal name. Wallpaper was AI edited from a user-supplied Fedora wallpaper and upscaled; Fedora marks remain their owners' trademarks. The source image's original licensing was not established in this session; review that before redistributing the wallpaper outside this personal fork.

## Recorded installed software

- Google Chrome: official RPM and Google repository; updated through DNF.
- Steam: RPM Fusion package `steam-1.0.0.87-1.fc44.x86_64` on the audited host.
- WezTerm: extracted nightly AppImage, user-local installation; Mac-derived Catppuccin Mocha config, 18-point text, dynamic tab titles, workspace and SSH-domain shortcuts. No SSH host file, keys, or credentials are included.
- ChatGPT, Claude Desktop, Grok Bot, Obsidian: native user-local Linux application bundles. Exact vendor artifact provenance and versions were not recovered, so no guessed automatic download links are used. Obtain current trusted packages and use the registration script above.
- Hermes: built from `NousResearch/hermes-agent` commit `939e45c91d751fadd94dcd1b873ac3cb44846213`; desktop package version 0.17.2. Runtime/provider setup remains separate. Build instructions belong to that upstream checkout.
- Neovim: LazyVim config, lockfile, theme integration, Neo-tree, and transparency customization. No plugin caches or editor history are included.

## Validated and outstanding

The running machine launched WezTerm, Files, Neovim, ChatGPT, Chrome, Claude, Grok Bot, Hermes and Obsidian. Four tiled windows measured 941×508. The user approved the lock preview, AM/PM clock, wallpaper, and name removal. NetworkManager, NVIDIA rendering, PipeWire, WirePlumber and the Hyprland portal were active.

Audio exposed only Dummy Output with analog ports reporting unavailable; audible output was not verified. Hermes provider setup and Obsidian NAS mapping remain outstanding. No NAS credentials or machine-specific storage resizing is automated. A temporary `--exclude=hyprtoolkit` avoided a COPR package mismatch; no permanent version pin is installed. A fresh-machine installation of this optional profile has not yet been validated.

## September 14 follow-up audit

All declared runtime dependencies are installed; DNF's package consistency check passes. Enabled repositories are Fedora 44, Fedora updates/Cisco codecs, RPM Fusion, the Hyprland COPR, and Google Chrome. Pacman, yay, and paru are absent. Fedora menus invoke DNF/RPM helpers; unsupported upstream package choices are hidden or rejected by the package map. The package menu now uses Fedora glyphs, and absent terminals are hidden from default-terminal selection. Chrome maps to its installed `google-chrome-stable` RPM. Chromium is no longer automatically included alongside Chrome.

Standalone WezTerm and native AI/Obsidian bundles remain outside RPM ownership; this is not a strictly RPM-only desktop. No application bundles or account data were removed. Audio still exposes only Dummy Output. The NVIDIA settings autostart recorded a failure, although the NVIDIA driver and compositor are running. These are outstanding runtime issues, not evidence of a missing declared package.
