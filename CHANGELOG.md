# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-04-03

**Code Health & Reliability**

### Fixed
- **Simple Mode no longer crashes at the end of installation** — Previously, running the script in Simple Mode (the default) would fail right after GitLab was successfully installed, leaving you without an installation log. Now the script completes cleanly and writes the log file as expected.
- **Let's Encrypt installations now show the correct SSL info** — The post-install summary and log file previously always showed self-signed certificate details, even when you chose Let's Encrypt. Now you'll see the right information for your SSL setup.

### Improved
- **Version number now shows in the interactive menu and `--help` output** — You can see which version of the script you're running at a glance.
- **~40% less internal code duplication** — Consolidated repeated output blocks into shared functions. This doesn't change what you see, but it means fewer places for bugs to hide in future updates.

## [1.2.0] - 2026-03-15

**Documentation & Code Quality**

### Improved
- **Completely rewritten README** — Cleaner layout with collapsible sections, so you can find what you need without scrolling through walls of text.
- **Script now passes shellcheck with zero warnings** — Fixes to quoting and variable handling make the script more robust on edge-case inputs.
- **Better onboarding** — New "Why This Script?" section and dynamic GitHub badges help you evaluate the project at a glance.

## [1.1.1] - 2026-01-11

**Smarter Defaults**

### Improved
- **60% fewer keystrokes for standard installations** — The script now auto-detects your next available VMID, gateway, DNS, and generates a GitLab URL from your container IP. Just press Enter for most prompts.

### Fixed
- **SSL certificate generation no longer fails silently** — Fixed a typo that could cause certificate creation to error out.
- **Installation summary now displays correctly** — GitHub and Support links were previously cut off.

## [1.1.0] - 2026-01-11

**Simple Storage Mode**

### Added
- **Simple Mode is now the default** — A single root filesystem that's easier to manage and expand. No more juggling separate volumes for most setups.
- **Advanced Mode still available** — If you need separate LVM volumes for compliance or granular snapshots, just pick option 2 or pass `--storage-mode advanced`.
- **Storage sizing guide** — Recommendations by team size so you don't have to guess.

### ⚠️ Breaking Changes
- **Default storage mode changed from Advanced to Simple.** If you have automation scripts that relied on the old default, add `--storage-mode advanced` to keep the same behaviour. Existing installations are not affected.

## [1.0.0] - 2025-01-04

**Initial Release**

One script to go from a bare Proxmox host to a running, security-hardened GitLab CE instance in ~15-20 minutes.

- **Interactive and non-interactive modes** — Guided setup for first-timers, or pass all parameters on the command line for automation.
- **Unprivileged LXC container** — Enhanced isolation out of the box.
- **Self-signed or Let's Encrypt SSL** — Pick what fits your network.
- **Security hardening** — TLS 1.2/1.3, HSTS, rate limiting, UFW firewall, and more — all configured automatically.
- **Automatic cleanup** — If a previous install failed, the script detects and offers to clean up leftover resources.
- **Specific version support** — Install the latest stable GitLab CE, or pin a specific version.
- **Tested on** Proxmox VE 8.x with Ubuntu 24.04 LXC.

[1.0.0]: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases/tag/v1.0.0
