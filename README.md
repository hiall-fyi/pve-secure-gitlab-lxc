# GitLab CE Secure Installation Script for Proxmox LXC

<div align="center">

![GitLab CE](https://img.shields.io/badge/GitLab-CE-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardened-00C853?style=for-the-badge&logo=security&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-Manual_Verified-brightgreen?style=for-the-badge&logo=checkmarx&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**A production-ready, security-hardened installation script for deploying GitLab Community Edition on Proxmox LXC containers.**

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-post-installation) • [Examples](#-version-management) • [Support](#-support)

---

### 🎯 Created by [@hiall-fyi](https://github.com/hiall-fyi)

<a href="https://buymeacoffee.com/hiallfyi" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" >
</a>

*If this script saves you time, consider buying me a coffee! ☕*

</div>

---

## 🎯 Features

### Storage Modes (NEW in v1.1.0)

Choose between two storage configurations based on your needs:

#### Simple Mode (Default) ⭐ Recommended for 90% of users

**What it is**: Single root filesystem containing all GitLab data

**Benefits**:
- ✅ **Automatic space sharing** - No more "log disk full but data disk empty"
- ✅ **Easier management** - One volume to monitor and expand
- ✅ **Simpler backups** - Single snapshot covers everything
- ✅ **More flexible** - Space automatically allocated where needed
- ✅ **Less planning** - Just specify total size, done!

**Perfect for**:
- Small to medium teams (1-50 users)
- Internal deployments
- Development/testing environments
- When you want simplicity over granular control

**Example**:
```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 50 \
  --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --storage local-lvm
```

---

#### Advanced Mode - For enterprise deployments

**What it is**: Separate LVM volumes for /etc/gitlab, /var/log/gitlab, /var/opt/gitlab

**Benefits**:
- ✅ **Independent snapshots** - Backup each volume separately
- ✅ **Granular quota enforcement** - Limit log growth independently
- ✅ **Separate backup schedules** - Different retention for logs vs data
- ✅ **Compliance ready** - Meet specific regulatory requirements

**Perfect for**:
- Enterprise deployments with compliance requirements
- Need to limit log growth independently
- Want separate backup schedules for different data types
- Require quota enforcement per volume

**Example**:
```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 120 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode advanced --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \
  --ip 192.168.1.120/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --storage local-lvm
```

---

#### Quick Comparison

| Feature | Simple Mode | Advanced Mode |
|---------|-------------|---------------|
| **Complexity** | Low ⭐ | Medium |
| **Setup Time** | 1 parameter | 4 parameters |
| **Management** | Easy | Requires planning |
| **Flexibility** | High (auto-sharing) | Medium (fixed sizes) |
| **Backup** | Single snapshot | Multiple snapshots |
| **Expansion** | One command | Per-volume commands |
| **Space Efficiency** | High | Can waste space |
| **Best For** | 90% of users | Enterprise/Compliance |

**💡 Recommendation**: Start with Simple Mode. You can always migrate to Advanced Mode later if needed.

### Core Functionality

- ✅ **Automated System Updates** - Ensures both Proxmox host and container are fully updated
- ✅ **Unprivileged Container** - Deploys GitLab in a secure, unprivileged LXC container
- ✅ **Flexible SSL Configuration** - Choose between self-signed (internal) or Let's Encrypt (public)
- ✅ **Security Hardening** - Comprehensive security configurations
- ✅ **Version Control** - Install latest stable or specific GitLab version
- ✅ **Network Flexibility** - Support for multiple network bridges (vmbr0, vmbr1, vmbr3, etc.)
- ✅ **Auto Cleanup** - Intelligent cleanup of existing containers and LVs
- ✅ **Fingerprint Tracking** - Easy identification of script-created resources

### Security Features

- 🔒 Unprivileged LXC container for enhanced isolation
- 🔒 Forced system updates (host + container)
- 🔒 **Flexible SSL**: Self-signed certificates (internal) or Let's Encrypt (public domains)
- 🔒 Strong cipher suites (TLS 1.2/1.3)
- 🔒 HTTPS redirect enforcement
- 🔒 Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy)
- 🔒 Rate limiting configuration
- 🔒 UFW firewall setup
- 🔒 Session management

### Storage Architecture

- 📦 Separate LVM volumes for better management:
  - `/etc/gitlab` - Configuration files
  - `/var/log/gitlab` - Log files
  - `/var/opt/gitlab` - Data files
- 📦 LVM tags for easy identification
- 📦 Easy backup and snapshot management

---

## 📋 Prerequisites

### System Requirements

- **Proxmox VE**: Version 7.0 or higher
- **Storage**: Minimum 150GB available LVM space
- **Memory**: Recommended 8GB+ for GitLab container
- **CPU**: Recommended 4+ cores
- **Network**: Working network configuration with internet access

### Access Requirements

- Root access to Proxmox host
- Ubuntu 24.04 LXC template (auto-downloaded if missing)

---

## 🚀 Quick Start

### Interactive Mode (Recommended for First-Time Users)

The script will guide you through the setup process:

```bash
./pve-secure-gitlab-lxc.sh
```

**What happens**:

**Step 1: Choose Storage Mode**
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

**Step 2: Basic Configuration**

If you selected Simple Mode:
```
Container ID (e.g., 110): 110
Container Name (e.g., gitlab): gitlab
CPU Cores (e.g., 4): 4
RAM in MB (e.g., 8192): 8192
Root Filesystem Size in GB (e.g., 50): 50    ← Just one size!
Container IP (e.g., 192.168.1.110/24): 192.168.1.110/24
Gateway (e.g., 192.168.1.1): 192.168.1.1
DNS Server (e.g., 8.8.8.8): 8.8.8.8
GitLab URL (e.g., https://gitlab.local): https://gitlab.local
LVM Storage VG Name (e.g., pve): pve
```

If you selected Advanced Mode:
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
Gateway (e.g., 192.168.1.1): 192.168.1.1
DNS Server (e.g., 8.8.8.8): 8.8.8.8
GitLab URL (e.g., https://gitlab.local): https://gitlab.local
LVM Storage VG Name (e.g., pve): pve
```

**Step 3: Confirmation & Installation**

The script shows a summary and asks for confirmation. After you confirm, it automatically:
1. ✅ Updates Proxmox host system
2. ✅ Creates unprivileged LXC container
3. ✅ Installs GitLab CE
4. ✅ Configures SSL certificate
5. ✅ Applies security hardening
6. ✅ Sets up firewall

**Total time**: ~15-20 minutes

---

### Non-Interactive Mode (For Automation)

#### Simple Mode Example (Recommended)

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

#### Advanced Mode Example

```bash
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

#### v1.0.0 Compatibility (Automatically uses Advanced Mode)

```bash
# Old v1.0.0 command still works!
./pve-secure-gitlab-lxc.sh \
  --vmid 110 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.110/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.local \
  --storage local-lvm
```

---

### 1. Download the Script

```bash
wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh
chmod +x pve-secure-gitlab-lxc.sh
```

### 2. Run Installation

See examples above for interactive or non-interactive mode.

### 3. Access GitLab

After installation completes:
1. Visit your GitLab URL (e.g., `https://gitlab.local`)
2. Login with username `root` and the password displayed at installation completion
3. **Change the root password immediately!**

---

## SSL Certificate Configuration

GitLab requires HTTPS for secure access. This script supports two SSL certificate types:

### Option 1: Self-Signed Certificate (Default)

**Best for**: Internal networks, development, testing

**Advantages**:
- ✅ Works immediately without external dependencies
- ✅ No domain registration required
- ✅ No internet access needed
- ✅ 10-year validity
- ✅ Perfect for `.local`, `.lan`, or private IP addresses

**Usage**:
```bash
./pve-secure-gitlab-lxc.sh ... --ssl-type self-signed
# or simply omit --ssl-type (self-signed is default)
```

**Browser Warning**: Self-signed certificates will show a security warning in browsers. This is normal and safe for internal use. See [Post-Installation](#post-installation) for how to handle this.

---

### Option 2: Let's Encrypt Certificate

**Best for**: Public-facing GitLab instances accessible from the internet

**Requirements**:
- ✅ Valid public domain name (e.g., `gitlab.example.com`)
- ✅ Domain must point to your server's public IP
- ✅ Ports 80 and 443 must be accessible from the internet
- ✅ Server must be reachable for Let's Encrypt validation

**Usage**:
```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 120 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 203.0.113.120/24 \
  --gateway 203.0.113.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.example.com \
  --storage local-lvm \
  --bridge vmbr0 \
  --ssl-type letsencrypt
```

**Important Notes**:
- Certificate auto-renews every 90 days
- Update contact email in `/etc/gitlab/gitlab.rb` after installation
- Ensure firewall allows ports 80/443 from internet
- DNS must be configured before running the script

**Troubleshooting Let's Encrypt**:
```bash
# Check certificate status
pct exec <VMID> -- gitlab-ctl status

# View Let's Encrypt logs
pct exec <VMID> -- cat /var/log/gitlab/nginx/error.log

# Manually trigger certificate renewal
pct exec <VMID> -- gitlab-ctl renew-le-certs
```

---

## 💾 Storage Configuration Guide

### Understanding Storage Modes

v1.1.0 introduces two storage modes to fit different use cases:

---

### Simple Mode (Recommended) ⭐

**Single root filesystem** - All GitLab data stored on root

**Sizing Recommendations**:

| Team Size | Recommended Size | Use Case |
|-----------|------------------|----------|
| 1-10 users | 30-50 GB | Small team, light usage |
| 10-50 users | 50-100 GB | Medium team, moderate CI/CD |
| 50+ users | 100-200+ GB | Large team, heavy CI/CD |

**Example**:
```bash
# Small team
--storage-mode simple --rootfs-size 50

# Medium team
--storage-mode simple --rootfs-size 100

# Large team
--storage-mode simple --rootfs-size 200
```

**Monitoring**:
```bash
# Check total usage
pct exec <VMID> -- df -h /

# Check GitLab data breakdown
pct exec <VMID> -- du -sh /etc/gitlab /var/log/gitlab /var/opt/gitlab
```

**Expanding**:
```bash
# Stop container
pct stop <VMID>

# Extend LV (add 50GB)
lvextend -L +50G /dev/pve/vm-<VMID>-disk-0

# Resize filesystem
e2fsck -f /dev/pve/vm-<VMID>-disk-0
resize2fs /dev/pve/vm-<VMID>-disk-0

# Start container
pct start <VMID>
```

---

### Advanced Mode - For Enterprise

**Separate LVM volumes** for granular control

**Sizing Recommendations**:

| Team Size | Boot | Config | Logs | Data | Total |
|-----------|------|--------|------|------|-------|
| 1-10 users | 20G | 2G | 10G | 50G | 82G |
| 10-50 users | 25G | 3G | 15G | 150G | 193G |
| 50+ users | 30G | 5G | 20G | 300G | 355G |

**Example**:
```bash
# Small team
--storage-mode advanced --bootdisk 20 --configdisk 2 --logdisk 10 --datadisk 50

# Medium team
--storage-mode advanced --bootdisk 25 --configdisk 3 --logdisk 15 --datadisk 150

# Large team
--storage-mode advanced --bootdisk 30 --configdisk 5 --logdisk 20 --datadisk 300
```

**Monitoring**:
```bash
# Check all volumes
pct exec <VMID> -- df -h

# Check specific volume
pct exec <VMID> -- df -h /var/opt/gitlab
```

**Expanding** (per volume):
```bash
# Extend data volume (add 50GB)
lvextend -L +50G /dev/pve/vm-<VMID>-gitlab-opt
pct exec <VMID> -- resize2fs /dev/mapper/pve-vm--<VMID>--gitlab--opt

# Extend log volume (add 10GB)
lvextend -L +10G /dev/pve/vm-<VMID>-gitlab-log
pct exec <VMID> -- resize2fs /dev/mapper/pve-vm--<VMID>--gitlab--log
```

---

### Migration: Advanced → Simple

If you have an existing Advanced Mode installation and want to consolidate:

**⚠️ Warning**: Backup first!

```bash
# 1. Backup GitLab
pct exec <VMID> -- gitlab-backup create

# 2. Stop container
pct stop <VMID>

# 3. Remove mount points from config
vi /etc/pve/lxc/<VMID>.conf
# Delete lines: mp0, mp1, mp2

# 4. Start and reconfigure
pct start <VMID>
pct exec <VMID> -- gitlab-ctl reconfigure

# 5. Remove old LVs and expand root
lvremove -f /dev/pve/vm-<VMID>-gitlab-etc
lvremove -f /dev/pve/vm-<VMID>-gitlab-log
lvremove -f /dev/pve/vm-<VMID>-gitlab-opt

# 6. Expand root with freed space
pct stop <VMID>
lvextend -L +15G /dev/pve/vm-<VMID>-disk-0
e2fsck -f /dev/pve/vm-<VMID>-disk-0
resize2fs /dev/pve/vm-<VMID>-disk-0
pct start <VMID>
```

See `gitlab/GITLAB_STORAGE_CONSOLIDATION.md` for detailed migration guide.

---

### Storage Best Practices

1. **Monitor regularly** - Set up alerts for 80% disk usage
2. **Plan for growth** - Estimate 20-30% annual growth for data
3. **Clean up regularly** - Remove old CI/CD artifacts and logs
4. **Use backup compression** - Saves significant space

### Cleanup Commands

```bash
# Clean old CI/CD artifacts (older than 30 days)
pct exec <VMID> -- gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# Clean old logs
pct exec <VMID> -- gitlab-ctl cleanup-logs

# Clean old backups (older than 7 days)
pct exec <VMID> -- find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete

# Clean Docker registry (if enabled)
pct exec <VMID> -- gitlab-rake gitlab:cleanup:orphan_registry_uploads
```

---

## 📖 Usage Examples

### Example 1: Small Team - Simple Mode (Recommended)

**Scenario**: Small team (5-10 users), internal network, want simplicity

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

**Result**:
- Container ID: 110
- Single 50GB root filesystem
- All GitLab data in one place
- Easy to manage and expand
- Perfect for small teams

---

### Example 2: Medium Team - Simple Mode

**Scenario**: Medium team (20-50 users), moderate CI/CD usage

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 120 \
  --hostname gitlab-dev \
  --cpu 6 \
  --ram 12288 \
  --storage-mode simple \
  --rootfs-size 100 \
  --ip 192.168.1.120/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.dev.local \
  --storage local-lvm
```

**Result**:
- Container ID: 120
- 6 CPU cores for better performance
- 12GB RAM for active development
- 100GB total storage
- Suitable for active development teams

---

### Example 3: Enterprise - Advanced Mode

**Scenario**: Enterprise deployment with compliance requirements

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 130 \
  --hostname gitlab-prod \
  --cpu 8 \
  --ram 16384 \
  --storage-mode advanced \
  --bootdisk 30 \
  --datadisk 300 \
  --logdisk 20 \
  --configdisk 5 \
  --ip 192.168.1.130/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.company.com \
  --storage local-lvm
```

**Result**:
- Container ID: 130
- Separate LVM volumes for granular control
- Independent snapshots per volume
- Meets compliance requirements
- Suitable for enterprise deployments

---

### Example 4: v1.0.0 Compatibility

**Scenario**: Existing automation scripts from v1.0.0

```bash
# Old v1.0.0 command still works!
./pve-secure-gitlab-lxc.sh \
  --vmid 140 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.140/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.local \
  --storage local-lvm
```

**Result**:
- Automatically uses Advanced Mode
- Backward compatible with v1.0.0
- No changes needed to existing scripts

---

### Example 5: Public Deployment with Let's Encrypt

**Scenario**: Public-facing GitLab with Let's Encrypt SSL

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 150 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --storage-mode simple \
  --rootfs-size 100 \
  --ip 203.0.113.150/24 \
  --gateway 203.0.113.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.example.com \
  --storage local-lvm \
  --ssl-type letsencrypt
```

**Result**:
- Public-facing GitLab
- Let's Encrypt SSL certificate
- Auto-renewal every 90 days
- Requires public domain and open ports 80/443

---
  --vmid 200 \
  --hostname gitlab-internal \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 50 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.200/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.company.local \
  --storage local-lvm \
  --bridge vmbr0
```

**Result**:
- Container ID: 200
- Internal IP: 192.168.1.200
- Total Storage: ~82GB (20GB boot + 50GB data + 10GB logs + 2GB config)
- Perfect for small teams with moderate repository sizes

---

## ✅ Quality Assurance

### Manual Verification

This script has been manually verified through:

**Installation Testing**:
- ✅ Fresh installation on Proxmox VE 8.x
- ✅ Ubuntu 24.04 LXC template compatibility
- ✅ Both Simple and Advanced storage modes
- ✅ Interactive and non-interactive modes
- ✅ Self-signed and Let's Encrypt SSL configurations

**Storage Testing**:
- ✅ Simple Mode: Single root filesystem (30GB, 50GB, 100GB)
- ✅ Advanced Mode: Separate LVM volumes (various sizes)
- ✅ Storage expansion procedures
- ✅ Migration from Advanced to Simple mode

**Security Verification**:
- ✅ Unprivileged container isolation
- ✅ SSL/TLS configuration (TLS 1.2/1.3)
- ✅ Security headers (HSTS, X-Frame-Options, CSP)
- ✅ UFW firewall rules
- ✅ Rate limiting configuration

**Compatibility Testing**:
- ✅ Backward compatibility with v1.0.0 parameters
- ✅ Multiple network bridges (vmbr0, vmbr1, vmbr3)
- ✅ Specific GitLab version installation
- ✅ Cleanup and reinstall scenarios

**Real-World Usage**:
- ✅ Production deployment on internal network
- ✅ Fresh installation with Simple Mode tested and working
- ✅ Fresh installation with Advanced Mode tested and working
- ✅ GitLab CE services operational (nginx, postgresql, redis, sidekiq, etc.)
- ✅ Manual migration from Advanced to Simple mode documented (see Migration Guide)

### Syntax Validation

```bash
# Script passes bash syntax check
bash -n pve-secure-gitlab-lxc.sh
# ✅ No syntax errors
```

---

## 🔄 Version Management

### Installing Latest Stable Version (Default)

Simply press Enter when prompted for GitLab version, or omit `--version` parameter:

```bash
./pve-secure-gitlab-lxc.sh --vmid 110 ... # (other parameters)
```

### Installing Specific Version

Specify the version number:

```bash
./pve-secure-gitlab-lxc.sh --vmid 110 ... --version 16.8.1
```

### Finding Available Versions

```bash
# On any Ubuntu/Debian system with GitLab repo added
apt-cache madison gitlab-ce

# Or check GitLab releases page
# https://about.gitlab.com/releases/categories/releases/
```

### Upgrading GitLab

```bash
# Enter container
pct enter <VMID>

# Create backup first!
gitlab-backup create

# Update package list
apt update

# Upgrade to latest version
apt upgrade gitlab-ce

# Or upgrade to specific version
apt install gitlab-ce=16.9.0-ce.0

# Reconfigure after upgrade
gitlab-ctl reconfigure
gitlab-ctl restart
```

---

## 📝 Post-Installation

### First Login

1. Access your GitLab URL
2. Login with:
   - **Username**: `root`
   - **Password**: Displayed at installation completion

⚠️ **Important**: Change the root password immediately!

### SSL Certificate Warning

Since the script uses a self-signed certificate, your browser will show a security warning.

**Option 1**: Accept the risk and continue
- Click "Advanced" → "Proceed to site"

**Option 2**: Add certificate to trusted store
```bash
# Export certificate from container
pct exec <VMID> -- cat /etc/gitlab/ssl/<hostname>.crt > gitlab.crt

# Add to your system's trusted certificate store
# macOS: sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain gitlab.crt
# Linux: sudo cp gitlab.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates
```

### Basic Configuration

1. **Change Root Password**
   - Profile Icon → Settings → Password

2. **Enable 2FA** (Recommended)
   - Settings → Account → Two-Factor Authentication

3. **Create Users**
   - Admin Area → Users → New User

4. **Create Projects**
   - New Project → Create blank project

5. **Add SSH Keys**
   - Settings → SSH Keys → Add new key

### Git Client Configuration

For self-signed certificates:

```bash
# Disable SSL verification globally (internal use only)
git config --global http.sslVerify false

# Or per repository
git config http.sslVerify false
```

---

## 🔧 Management Commands

### GitLab Service Management

```bash
# Check all services status
pct exec <VMID> -- gitlab-ctl status

# Restart all services
pct exec <VMID> -- gitlab-ctl restart

# Stop all services
pct exec <VMID> -- gitlab-ctl stop

# Start all services
pct exec <VMID> -- gitlab-ctl start

# Reconfigure GitLab
pct exec <VMID> -- gitlab-ctl reconfigure

# View live logs
pct exec <VMID> -- gitlab-ctl tail

# View specific service logs
pct exec <VMID> -- gitlab-ctl tail nginx
pct exec <VMID> -- gitlab-ctl tail postgresql
```

### Container Management

```bash
# Enter container
pct enter <VMID>

# Check container status
pct status <VMID>

# Stop container
pct stop <VMID>

# Start container
pct start <VMID>

# Reboot container
pct reboot <VMID>

# Check resource usage
pct exec <VMID> -- df -h
pct exec <VMID> -- free -h
```

### Identifying Script-Created Resources

```bash
# List all containers created by this script
pct list | grep -i gitlab

# Check container description for fingerprint
pct config <VMID> | grep description

# List LVs with script tags
lvs -o lv_name,lv_tags | grep gitlab-ce-secure-install

# List all LVs for specific VMID
lvs -o lv_name,lv_tags | grep vmid-<VMID>
```

### Backup and Restore

```bash
# Manual GitLab backup
pct exec <VMID> -- gitlab-backup create

# List backups
pct exec <VMID> -- ls -lh /var/opt/gitlab/backups/

# Restore backup
pct exec <VMID> -- gitlab-ctl stop puma
pct exec <VMID> -- gitlab-ctl stop sidekiq
pct exec <VMID> -- gitlab-backup restore BACKUP=<timestamp>
pct exec <VMID> -- gitlab-ctl restart
pct exec <VMID> -- gitlab-rake gitlab:check SANITIZE=true

# Container snapshot (Proxmox level)
vzdump <VMID> --mode snapshot --compress zstd --storage local
```

---

## 🔒 Security Best Practices

### Password Management

- Use strong passwords (minimum 12 characters with mixed case, numbers, symbols)
- Change passwords regularly (recommended every 90 days)
- Never share accounts

### Access Control

- Limit access to necessary IP ranges only
- Use SSH keys instead of passwords
- Review user permissions regularly

### Regular Maintenance

- Update system packages monthly
- Update GitLab quarterly
- Review logs regularly
- Monitor resource usage

### Backup Strategy

- Implement daily automated backups
- Retain at least 7 days of backups
- Test restore procedures regularly

### Automated Backup Setup

```bash
# Enter container
pct enter <VMID>

# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1

# Clean up backups older than 7 days
0 3 * * * find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete
```

---

## 🐛 Troubleshooting

### GitLab Service Won't Start

```bash
# Check logs
pct exec <VMID> -- gitlab-ctl tail

# Check configuration
pct exec <VMID> -- gitlab-rake gitlab:check

# Reconfigure
pct exec <VMID> -- gitlab-ctl reconfigure
```

### Cannot Access GitLab

```bash
# Check firewall
pct exec <VMID> -- ufw status

# Check nginx status
pct exec <VMID> -- gitlab-ctl status nginx

# Check SSL certificate
pct exec <VMID> -- ls -l /etc/gitlab/ssl/
```

### Out of Memory

```bash
# Increase container RAM
pct set <VMID> -memory 16384

# Reboot container
pct reboot <VMID>
```

### Disk Space Issues

```bash
# Check disk usage
pct exec <VMID> -- df -h

# Clean old logs
pct exec <VMID> -- gitlab-ctl cleanup-logs

# Remove old backups
pct exec <VMID> -- find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete
```

### Reset Root Password

```bash
# Enter container
pct enter <VMID>

# Open Rails console
gitlab-rails console

# Reset password
user = User.find_by(username: 'root')
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save!
exit
```

---

## 📊 Performance Tuning

### Small Teams (< 10 users)

```ruby
# /etc/gitlab/gitlab.rb
postgresql['shared_buffers'] = '256MB'
sidekiq['max_concurrency'] = 10
puma['worker_processes'] = 2
```

### Medium Teams (10-50 users)

```ruby
postgresql['shared_buffers'] = '512MB'
sidekiq['max_concurrency'] = 20
puma['worker_processes'] = 4
```

### Large Teams (> 50 users)

```ruby
postgresql['shared_buffers'] = '1GB'
sidekiq['max_concurrency'] = 30
puma['worker_processes'] = 8
```

After modifications:
```bash
pct exec <VMID> -- gitlab-ctl reconfigure
pct exec <VMID> -- gitlab-ctl restart
```

---

## 📚 Resources

- [GitLab Official Documentation](https://docs.gitlab.com/)
- [GitLab CE Installation Guide](https://about.gitlab.com/install/)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)
- [GitLab Backup and Restore](https://docs.gitlab.com/ee/raketasks/backup_restore.html)

---

## 🆘 Support

If you encounter issues:

1. Check installation log: `/var/log/gitlab-ce-install-<VMID>.log`
2. Check GitLab logs: `pct exec <VMID> -- gitlab-ctl tail`
3. Check container logs: `pct exec <VMID> -- journalctl -xe`
4. Open an issue on [GitHub](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues)

---

## 📄 License

MIT License - Feel free to use and modify for your needs.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## ⭐ Star History

If you find this script useful, please consider giving it a star!

[![Star History Chart](https://api.star-history.com/svg?repos=hiall-fyi/pve-secure-gitlab-lxc&type=Date)](https://star-history.com/#hiall-fyi/pve-secure-gitlab-lxc&Date)

---

<div align="center">

### 💖 Support This Project

If this script saved you time and effort, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hiallfyi)

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**

</div>

---

**Version**: 1.1.1  
**Last Updated**: 2026-01-11  
**Tested On**: Proxmox VE 8.x with Ubuntu 24.04 LXC

## Changelog

See `CHANGELOG.md` for version history and changes.

## What's New in v1.1.1

- 🎯 **Smart Defaults** - Auto-detect VMID, gateway, DNS, and GitLab URL
- ⚡ **Faster Installation** - Just press Enter to use sensible defaults
- 🐛 **SSL Bug Fixes** - Fixed certificate generation and HTTP/HTTPS handling
- 📝 **Better Prompts** - Clear `(default: value)` format for all parameters

See `RELEASE_NOTES_v1.1.1.md` for detailed information.

## What's New in v1.1.0

- ⭐ **Simple Storage Mode** - New default, single root filesystem
- 🔧 **Advanced Storage Mode** - Previous separate LVM volumes approach (still available)
- 📊 **Storage Mode Selection** - Interactive prompt to choose your preferred mode
- 📝 **Improved Documentation** - Clear comparison and migration guide

See `RELEASE_NOTES_v1.1.0.md` for detailed information.
