# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-05-21

**Audit pass — security, correctness, and consistency fixes**

### ⚠️ Breaking Changes
- **`--le-email <address>` is now required when `--ssl-type letsencrypt`** — Previous versions silently registered Let's Encrypt against a hardcoded `admin@example.com`. The script now refuses to start without a real contact address. **Migration:** add `--le-email you@example.com` to any non-interactive automation that passes `--ssl-type letsencrypt`. Self-signed installs are unaffected.
- **`--storage <vg>` now governs the rootfs as well as the mount-point volumes** — Earlier versions silently routed the rootfs to `local-lvm` regardless of what you passed. If you've been relying on that quirk (e.g. you passed `--storage pve` but expected the rootfs on `local-lvm`), you'll need to either name `local-lvm` explicitly or accept that the rootfs lands on the VG you named. For most users this is a fix, not a break — but it changes observed behaviour, so it's flagged.

### Fixed
- **Coloured output renders properly in the interactive menu, summary screens, and Proxmox container Notes** — The escape codes were quoted in a way that only worked inside `echo -e`. Heredocs and plain `echo` were leaking literal `\033[…m` in front of every line. All three render in colour now.
- **Initial root password log file is no longer world-readable** — `/var/log/gitlab-ce-install-<VMID>.log` contains the initial GitLab root password and was created with default permissions (0644). Now created with mode 0600.
- **`/etc/gitlab/gitlab.rb` is now written in a single canonical block** — Two heredocs used to write the file in two stages, leaving overlapping stanzas to reconcile if you ever opened the file. One write now produces the final config end-to-end.
- **Proxmox container Notes show the correct SSL type** — The Markdown Notes attached to the LXC always claimed "Self-Signed SSL — 10-year validity", even when you picked Let's Encrypt. Now branches on `--ssl-type` like the on-screen summary already did.
- **Empty initial-password fallback works** — When the password extraction returned nothing, the `N/A` fallback never fired (the pipeline still exited 0). The summary used to show a blank password; it now falls back with a hint to run `gitlab-rake gitlab:password:reset` instead.

### Improved
- **Step numbering removed from progress headings** — The headings used to read `Step 1 → Step 2 → Step 1 (Container) → Step 3 → Step 6`, which looked like a crashed-and-restarted script. Sections now describe what's happening without the number.
- **Ubuntu 24.04 template auto-download picks the latest available patch revision** — Previously hardcoded to `ubuntu-24.04-standard_24.04-2_amd64.tar.zst` and would fail once Canonical / Proxmox shipped `-3`. Now resolves the latest via `pveam available`.
- **Stricter LV format check in Advanced Mode** — `mk_lv_if_missing` used to accept any existing filesystem on a recycled LV. Now refuses anything other than ext4 with an actionable error.
- **`pct enter` line in the post-install summary mentions it drops you into a root shell** — Small clarification for first-time users.
- **Internal `HOSTNAME` variable renamed to `CT_HOSTNAME`** — Avoids shadowing bash's built-in `$HOSTNAME`. No user-visible change.
- **Proxmox VE prerequisite documented consistently as 8.x** — README and CHANGELOG now agree on the supported version, matching the Ubuntu 24.04 template the script relies on.

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
- **New "Why This Script?" section in the README** — Plus dynamic GitHub badges (stars, forks, issues, last commit) at the top.

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
