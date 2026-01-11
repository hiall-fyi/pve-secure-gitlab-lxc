# Release Notes - v1.1.0

**Release Date**: 2026-01-11  
**Type**: Minor Update (Feature Addition)

---

## 🎉 What's New

### Simple Storage Mode (Default)

The biggest change in v1.1.0 is the introduction of **Simple Storage Mode** as the new default. Based on real-world usage and feedback, we've learned that most users don't need the complexity of separate LVM volumes.

**Simple Mode Benefits**:
- ✅ Single root filesystem - all GitLab data in one place
- ✅ Automatic space sharing - no more "log disk full but data disk empty"
- ✅ Easier management - one volume to monitor and expand
- ✅ Simpler backups - single snapshot covers everything
- ✅ More flexible - space automatically allocated where needed

**When to Use Simple Mode**:
- Small to medium teams (1-50 users)
- Internal deployments
- Development/testing environments
- When you want simplicity over granular control
- **Recommended for 90% of use cases**

---

## 🔧 Advanced Storage Mode (Still Available)

Don't worry! The previous separate LVM volumes approach is still fully supported as **Advanced Mode**.

**Advanced Mode Benefits**:
- ✅ Separate LVM volumes for /etc/gitlab, /var/log/gitlab, /var/opt/gitlab
- ✅ Independent snapshots for each volume
- ✅ Granular quota enforcement
- ✅ Separate backup schedules

**When to Use Advanced Mode**:
- Enterprise deployments with specific compliance requirements
- Need to limit log growth independently
- Want separate backup schedules for different data types
- Require quota enforcement per volume

---

## 📊 Storage Mode Comparison

| Feature | Simple Mode | Advanced Mode |
|---------|-------------|---------------|
| **Complexity** | Low | Medium |
| **Management** | Easy | Requires planning |
| **Flexibility** | High (auto-sharing) | Medium (fixed sizes) |
| **Backup** | Single snapshot | Multiple snapshots |
| **Expansion** | One command | Per-volume commands |
| **Best For** | 90% of users | Enterprise/Compliance |

---

## 🔄 What Changed from v1.0.0

### v1.0.0 Interactive Flow (Old)

```bash
./pve-secure-gitlab-lxc.sh
```

**Old Flow** - Always asked for separate disk sizes:
```
Container ID (e.g., 200): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
Boot Disk Size in GB (e.g., 20): 20          ← Separate boot disk
Data Disk Size in GB (e.g., 100): 100        ← Separate data disk
Log Disk Size in GB (e.g., 10): 10           ← Separate log disk
Config Disk Size in GB (e.g., 2): 2          ← Separate config disk
Container IP (e.g., 192.168.1.200/24): 192.168.1.110/24
...
```

**Result**: 4 separate LVM volumes, complex management

---

### v1.1.0 Interactive Flow (New)

```bash
./pve-secure-gitlab-lxc.sh
```

**New Flow** - Asks for storage mode first:

**Step 1: Choose Storage Mode** ⭐ NEW!
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Storage Configuration Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Choose storage configuration:

  1. Simple Mode (Recommended) ⭐
     • Single root filesystem
     • All GitLab data on root
     • Easier management
     • Flexible space allocation
     • Best for most users

  2. Advanced Mode
     • Separate LVM volumes (like v1.0.0)
     • Granular control
     • Independent snapshots
     • More complex management

Select mode (1 or 2, default: 1): 1
```

**Step 2a: If Simple Mode (NEW)**
```
Container ID (e.g., 110): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
Root Filesystem Size in GB (e.g., 50): 50    ← Single size! ⭐
Container IP (e.g., 192.168.1.110/24): 192.168.1.110/24
...
```

**Result**: 1 root filesystem, simple management ✅

**Step 2b: If Advanced Mode (Same as v1.0.0)**
```
Container ID (e.g., 110): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
Boot Disk Size in GB (e.g., 20): 20
Data Disk Size in GB (e.g., 100): 100
Log Disk Size in GB (e.g., 10): 10
Config Disk Size in GB (e.g., 2): 2
Container IP (e.g., 192.168.1.110/24): 192.168.1.110/24
...
```

**Result**: 4 separate LVM volumes (same as v1.0.0)

---

## 🚀 Quick Start Examples

### Interactive Mode Flow (Recommended for First-Time Users)

When you run the script without parameters, you'll see:

```bash
./pve-secure-gitlab-lxc.sh
```

**Step 1: Storage Mode Selection**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Storage Configuration Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Choose storage configuration:

  1. Simple Mode (Recommended) ⭐
     • Single root filesystem
     • All GitLab data on root
     • Easier management
     • Flexible space allocation
     • Best for most users

  2. Advanced Mode
     • Separate LVM volumes
     • Granular control
     • Independent snapshots
     • More complex management

Select mode (1 or 2, default: 1): 
```

**Step 2: Basic Configuration** (if Simple Mode selected)
```
Container ID (e.g., 110): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
Root Filesystem Size in GB (e.g., 50): 50
Container IP (e.g., 192.168.1.110/24): 192.168.1.110/24
Gateway (e.g., 192.168.1.1): 192.168.1.1
DNS Server (e.g., 8.8.8.8): 8.8.8.8
GitLab URL (e.g., https://gitlab.local): https://gitlab.local
LVM Storage VG Name (e.g., pve): pve
```

**Step 3: Confirmation**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Container ID    : 110
  Hostname        : gitlab
  CPU Cores       : 4
  RAM             : 8192 MB
  Storage Mode    : Simple (Single Root Filesystem) ⭐
  Root Size       : 50 GB
  IP Address      : 192.168.1.110/24
  Gateway         : 192.168.1.1
  DNS             : 8.8.8.8
  GitLab URL      : https://gitlab.local
  Storage VG      : pve
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Confirm the above configuration is correct? (yes/no): yes
```

Then the script automatically:
1. ✅ Updates Proxmox host system
2. ✅ Creates unprivileged LXC container
3. ✅ Installs GitLab CE
4. ✅ Configures SSL certificate
5. ✅ Applies security hardening
6. ✅ Sets up firewall

**Total time**: ~15-20 minutes

---

### Simple Mode (Non-Interactive)

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 110 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --storage-mode simple \
  --rootfs-size 50 \
  --ip 192.168.1.110/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.local \
  --storage local-lvm
```

### Advanced Mode (Previous Default)

```bash
# Non-interactive mode with separate volumes
./pve-secure-gitlab-lxc.sh \
  --vmid 120 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --storage-mode advanced \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.120/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.local \
  --storage local-lvm
```

---

## 🔄 Migration Guide

### For Existing v1.0.0 Users

**Your existing installations continue to work unchanged!** No action required.

If you want to consolidate to Simple Mode (optional):

1. **Backup your GitLab data**
   ```bash
   pct exec <VMID> -- gitlab-backup create
   ```

2. **Stop the container**
   ```bash
   pct stop <VMID>
   ```

3. **Edit container config** - Remove mount points from `/etc/pve/lxc/<VMID>.conf`
   ```bash
   # Remove these lines:
   # mp0: /dev/pve/vm-<VMID>-gitlab-etc,mp=/etc/gitlab,backup=0
   # mp1: /dev/pve/vm-<VMID>-gitlab-log,mp=/var/log/gitlab,backup=0
   # mp2: /dev/pve/vm-<VMID>-gitlab-opt,mp=/var/opt/gitlab,backup=0
   ```

4. **Start container and reconfigure**
   ```bash
   pct start <VMID>
   pct exec <VMID> -- gitlab-ctl reconfigure
   ```

5. **Remove old LVs and expand root**
   ```bash
   lvremove -f /dev/pve/vm-<VMID>-gitlab-etc
   lvremove -f /dev/pve/vm-<VMID>-gitlab-log
   lvremove -f /dev/pve/vm-<VMID>-gitlab-opt
   
   # Expand root with freed space
   lvresize -L +5G /dev/pve/vm-<VMID>-disk-0
   
   # Resize filesystem (container must be stopped)
   pct stop <VMID>
   e2fsck -f /dev/pve/vm-<VMID>-disk-0
   resize2fs /dev/pve/vm-<VMID>-disk-0
   pct start <VMID>
   ```

**Note**: This migration is optional. Your existing setup works perfectly fine!

---

## 💡 Sizing Recommendations

### Simple Mode

| Team Size | Recommended Size | Use Case |
|-----------|------------------|----------|
| 1-10 users | 30-50 GB | Small team, light usage |
| 10-50 users | 50-100 GB | Medium team, moderate CI/CD |
| 50+ users | 100-200+ GB | Large team, heavy CI/CD |

### Advanced Mode

| Team Size | Boot | Config | Logs | Data | Total |
|-----------|------|--------|------|------|-------|
| 1-10 users | 20G | 2G | 10G | 50G | 82G |
| 10-50 users | 25G | 3G | 15G | 150G | 193G |
| 50+ users | 30G | 5G | 20G | 300G | 355G |

---

## 🐛 Bug Fixes

- Fixed over-provisioned storage in separate volumes
- Improved space utilization and flexibility
- Better handling of storage growth patterns

---

## ⚠️ Breaking Changes

**Default storage mode changed from Advanced to Simple**

If you're using automation scripts with v1.0.0 parameters, they will automatically use Advanced Mode for backward compatibility. No changes needed!

To explicitly use Simple Mode in automation:
```bash
--storage-mode simple --rootfs-size 50
```

---

## 📝 Technical Details

### Simple Mode Implementation
- Single root filesystem (`/`)
- All GitLab data stored on root
- Typical size: 30-200GB depending on team size
- Easy to expand: `lvresize` + `resize2fs`

### Advanced Mode Implementation
- Separate LVM volumes:
  - `/etc/gitlab` - Configuration files
  - `/var/log/gitlab` - Log files
  - `/var/opt/gitlab` - Data files (repositories, uploads, etc.)
- Independent management per volume
- Requires more planning and monitoring

### Backward Compatibility
- v1.0.0 parameters automatically trigger Advanced Mode
- Existing installations unaffected
- No breaking changes for existing users

---

## 🙏 Acknowledgments

This update is based on real-world experience and user feedback. Special thanks to everyone who provided insights on storage management challenges!

---

## 📚 Resources

- [Full Changelog](CHANGELOG.md)
- [README](README.md)
- [GitHub Repository](https://github.com/hiall-fyi/pve-secure-gitlab-lxc)
- [Report Issues](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues)

---

## ☕ Support This Project

If this update makes your life easier, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hiallfyi)

---

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**
