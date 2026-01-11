# Release Notes - v1.1.1

**Release Date**: 2026-01-11  
**Type**: Patch Release (UX Improvements + Bug Fixes)

---

## 🎯 Overview

This patch release significantly improves the interactive installation experience by adding smart defaults for all configuration parameters, and fixes critical SSL certificate generation bugs. Users can now complete installation much faster by simply pressing Enter to accept sensible defaults.

---

## ✨ What's New

### Smart Defaults for Interactive Mode

**Before v1.1.1**: Users had to manually type every single value

```text
Container ID (e.g., 200): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
...
```

**After v1.1.1**: Just press Enter to use defaults

```text
Container ID (default: 110): ⏎
Container Name (default: gitlab): ⏎
CPU Cores (default: 4): ⏎
RAM in MB (default: 8192): ⏎
...
```

### Auto-Detection Features

1. **VMID Auto-Detection**
   - Automatically finds next available container ID using Proxmox API
   - No need to manually check which IDs are in use

2. **Network Auto-Detection**
   - Detects default gateway from system configuration
   - Uses gateway IP as DNS server (or falls back to 8.8.8.8)

3. **URL Auto-Generation**
   - Automatically generates GitLab URL based on container IP
   - Example: IP `192.168.1.100/24` → URL `http://192.168.1.100`

---

## 📋 Complete Default Values

| Parameter | Default Value | Notes |
|-----------|---------------|-------|
| Container ID | Next available VMID | Auto-detected via Proxmox API |
| Container Name | `gitlab` | Standard name |
| CPU Cores | `4` | Recommended for GitLab |
| RAM | `8192` MB | Recommended for GitLab |
| Root Filesystem (Simple) | `50` GB | Medium team size |
| Boot Disk (Advanced) | `20` GB | System files |
| Data Disk (Advanced) | `100` GB | GitLab data |
| Log Disk (Advanced) | `10` GB | Log files |
| Config Disk (Advanced) | `2` GB | Configuration |
| Gateway | Auto-detected | From system routing table |
| DNS | Gateway IP or `8.8.8.8` | Auto-detected |
| GitLab URL | `http://<container-ip>` | Auto-generated |
| LVM Storage VG | `pve` | Standard Proxmox VG |
| GitLab Version | Latest stable | Official recommendation |
| Network Bridge | `vmbr0` | Default Proxmox bridge |

**Only Container IP requires manual input** (environment-specific)

---

## 🐛 Critical Bug Fixes

### Fixed: SSL Certificate Generation Typo

**Issue**: OpenSSL command had syntax error `days 3650 \\ 3650` causing certificate generation to fail.

**Fix**: Corrected to `days 3650` for proper 10-year certificate validity.

**Impact**: Self-signed SSL certificates now generate correctly without errors.

### Fixed: SSL/HTTP Protocol Mismatch

**Issue**: Script would generate SSL certificates even for HTTP URLs, then apply SSL configuration to nginx, causing GitLab to fail to start with 502 Bad Gateway errors.

**Example of Bug**:

```bash
# User enters HTTP URL
GitLab URL: http://192.168.1.100

# Script incorrectly:
1. Skips SSL cert generation (correct)
2. But still applies SSL config to nginx (wrong!)
3. nginx tries to redirect to HTTPS with missing certs
4. GitLab fails to start → 502 Bad Gateway
```

**Fix**: Auto-adjust `SSL_TYPE` based on URL protocol:
- `http://` URLs → `SSL_TYPE="none"` (no SSL config)
- `https://` URLs → `SSL_TYPE="self-signed"` (generate SSL cert)

**Impact**: HTTP and HTTPS URLs now work correctly without manual SSL_TYPE configuration.

### Fixed: Confusing Prompts

**Issue**: Prompts like `LVM Storage VG Name (e.g., pve):` appeared to suggest `pve` was the default, but pressing Enter resulted in an empty value and validation error.

**Fix**: Changed to `LVM Storage VG Name (default: pve):` and actually uses `pve` as default when Enter is pressed.

---

## 🚀 Installation

### Interactive Mode (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh)
```

**New Experience**:

1. Select storage mode (Simple/Advanced)
2. Enter container IP (e.g., `192.168.1.100/24`)
3. Press Enter for all other values to use defaults
4. Confirm and install

**Time Saved**: ~60% fewer keystrokes for standard installations

### Non-Interactive Mode (Unchanged)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh) \
  --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 50 \
  --ip 192.168.1.100/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url http://192.168.1.100 --storage pve --bridge vmbr0
```

---

## 🔄 Upgrade from v1.1.0

**No action required** - This is a UX improvement and bug fix release. Existing installations continue to work unchanged.

If you want to try the new interactive experience:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh)
```

---

## 📊 User Experience Improvements

### Before v1.1.1

- ❌ Had to type every single value
- ❌ No indication of recommended values
- ❌ Unclear which values were standard
- ❌ Time-consuming for standard setups
- ❌ Easy to make typos
- ❌ SSL certificate generation errors
- ❌ HTTP URLs would fail with SSL config

### After v1.1.1

- ✅ Press Enter to use sensible defaults
- ✅ Clear `(default: value)` format
- ✅ Auto-detection where possible
- ✅ Much faster installation
- ✅ Fewer opportunities for errors
- ✅ SSL certificates generate correctly
- ✅ HTTP and HTTPS URLs both work properly

---

## 🧪 Testing

This release has been tested on:

- ✅ Proxmox VE 8.x
- ✅ Ubuntu 24.04 LXC template
- ✅ Both Simple and Advanced storage modes
- ✅ Interactive mode with all defaults
- ✅ Interactive mode with custom values
- ✅ Non-interactive mode (unchanged)
- ✅ HTTP URLs (no SSL)
- ✅ HTTPS URLs (self-signed SSL)

---

## 📈 What's Changed

### Files Modified

- `pve-secure-gitlab-lxc.sh` - Added smart defaults + fixed SSL bugs
- `CHANGELOG.md` - Added v1.1.1 entry
- `RELEASE_NOTES_v1.1.1.md` - This file

### Code Changes

- Added VMID auto-detection using `pvesh get /cluster/nextid`
- Added gateway auto-detection using `ip route`
- Added default value handling with `${VAR:-default}` pattern
- Improved prompt format to show `(default: value)`
- Fixed openssl command typo (`days 3650 \\ 3650` → `days 3650`)
- Added SSL_TYPE auto-adjustment based on URL protocol
- Added HTTP mode support (no SSL config for HTTP URLs)

---

## 🔜 What's Next

Future releases will focus on:

- Additional auto-detection features
- Configuration templates for common scenarios
- Post-installation configuration wizard
- Backup and restore automation

---

## 💬 Support

If you encounter any issues:

1. Check the [documentation](README.md)
2. Review installation logs
3. Open an issue on [GitHub](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues)

---

## 🙏 Acknowledgments

Thanks to users who provided feedback on the installation experience and reported SSL certificate bugs!

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**

If this script saves you time, consider [buying me a coffee](https://buymeacoffee.com/hiallfyi)! ☕
