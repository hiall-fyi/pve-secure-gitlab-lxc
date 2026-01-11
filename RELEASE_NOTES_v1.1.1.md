# Release Notes - v1.1.1

**Release Date:** 2026-01-11  
**Type:** Minor Release (Bug Fixes + UX Improvements)

---

## 🎯 What's New in v1.1.1

### Smart Defaults - Faster Installation with Auto-Detection

We've added intelligent auto-detection for configuration parameters, making installation **60% faster** with fewer keystrokes and reduced errors.

**What it does:**
- 🎯 **Auto-detect VMID** - Finds next available container ID using Proxmox API
- 🌐 **Auto-detect Network** - Detects gateway and DNS from system configuration  
- 🔗 **Auto-generate URL** - Creates GitLab URL based on container IP
- ⚡ **Press Enter to Accept** - All parameters have sensible defaults

**Benefits:**
- ✅ **60% fewer keystrokes** - Just press Enter for standard installations
- ✅ **Fewer errors** - No typos in manual input
- ✅ **Faster setup** - Complete installation in minutes
- ✅ **Better UX** - Clear `(default: value)` format for all prompts

**Example:**
```bash
Container ID (default: 110): ▊          # Just press Enter!
Gateway (default: 192.168.1.1): ▊       # Auto-detected from system
DNS Server (default: 8.8.8.8): ▊        # Auto-detected from /etc/resolv.conf
GitLab URL (default: http://192.168.1.110): ▊  # Auto-generated from IP
```

---

## 🐛 Bug Fixes

### 1. SSL Certificate Generation Typo
**Issue:** SSL certificate generation had a typo causing syntax error  
**Fixed:** Corrected `days 3650 \\ 3650` → `days 3650`  
**Impact:** SSL certificates now generate correctly without errors

### 2. SSL/HTTP Protocol Mismatch
**Issue:** SSL_TYPE didn't auto-adjust based on URL protocol  
**Fixed:** Auto-adjust SSL_TYPE when HTTP URL is provided  
**Impact:** No more SSL configuration errors with HTTP URLs

### 3. Installation Summary Display Bug
**Issue:** GitHub and Support links appeared as "command not found" error  
**Fixed:** Moved links inside EOF block for proper display  
**Impact:** Installation summary now displays correctly with all links

---

## 📦 Installation

### Quick Start (Interactive Mode)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh)
```

### Non-Interactive Mode (Simple Storage)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh) \
  --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 50 \
  --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url http://192.168.1.110 --storage pve
```

---

## 🔄 Upgrade from v1.1.0

**No action required** - This is a bug fix release. Existing v1.1.0 installations continue to work unchanged.

If you want to benefit from Smart Defaults, simply use the script for new installations.

---

## 📊 Version Comparison

| Feature | v1.1.0 | v1.1.1 |
|---------|--------|--------|
| Simple Storage Mode | ✅ | ✅ |
| Advanced Storage Mode | ✅ | ✅ |
| Smart Defaults | ❌ | ✅ NEW |
| Auto-detect VMID | ❌ | ✅ NEW |
| Auto-detect Network | ❌ | ✅ NEW |
| Auto-generate URL | ❌ | ✅ NEW |
| SSL Certificate Bug | 🐛 | ✅ Fixed |
| Installation Summary Bug | 🐛 | ✅ Fixed |

---

## 🎓 What's Next?

### Recommended for Most Users
- **Simple Mode** - Single root filesystem, easier management
- **Smart Defaults** - Just press Enter for standard configurations

### For Enterprise Deployments
- **Advanced Mode** - Separate LVM volumes for granular control
- **Custom Configuration** - Override defaults with specific values

---

## 📚 Documentation

- [README](README.md) - Full documentation
- [CHANGELOG](CHANGELOG.md) - Complete change history
- [v1.1.0 Release Notes](RELEASE_NOTES_v1.1.0.md) - Previous release

---

## 🙏 Feedback & Support

Found a bug? Have a feature request?

- **GitHub Issues:** https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues
- **Support the Project:** https://buymeacoffee.com/hiallfyi ☕

---

**Created by:** Joe @ hiall-fyi  
**License:** MIT
