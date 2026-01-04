# GitLab CE Secure Installation Script for Proxmox LXC

<div align="center">

![GitLab CE](https://img.shields.io/badge/GitLab-CE-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardened-00C853?style=for-the-badge&logo=security&logoColor=white)
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

### 1. Download the Script

```bash
wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh
chmod +x pve-secure-gitlab-lxc.sh
```

### 2. Run Installation

**Interactive Mode** (Recommended for first-time users):
```bash
./pve-secure-gitlab-lxc.sh
```

**Non-Interactive Mode** (For automation):
```bash
# Internal deployment with self-signed certificate (default)
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
  --url https://gitlab.example.com \
  --storage local-lvm \
  --bridge vmbr0

# Public deployment with Let's Encrypt
./pve-secure-gitlab-lxc.sh \
  --vmid 115 \
  --hostname gitlab \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 203.0.113.115/24 \
  --gateway 203.0.113.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.example.com \
  --storage local-lvm \
  --bridge vmbr0 \
  --ssl-type letsencrypt
```

### 3. Access GitLab

After installation completes:
1. Visit your GitLab URL (e.g., `https://gitlab.local.lan`)
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

### Understanding GitLab Storage Requirements

GitLab uses four separate storage volumes for better management and performance:

| Volume | Mount Point | Purpose | Growth Rate | Recommended Size |
|--------|-------------|---------|-------------|------------------|
| **Boot Disk** | `/` | OS and GitLab binaries | Low | 20-30 GB |
| **Config Disk** | `/etc/gitlab` | Configuration files | Very Low | 1-5 GB |
| **Log Disk** | `/var/log/gitlab` | Application logs | Medium | 10-20 GB |
| **Data Disk** | `/var/opt/gitlab` | Repositories, uploads, artifacts | High | 50-500+ GB |

### Sizing Recommendations by Team Size

#### Small Team (1-10 users)
```bash
--bootdisk 20    # 20 GB for OS
--configdisk 2   # 2 GB for configs
--logdisk 10     # 10 GB for logs
--datadisk 50    # 50 GB for data
# Total: ~82 GB
```

#### Medium Team (10-50 users)
```bash
--bootdisk 25    # 25 GB for OS
--configdisk 3   # 3 GB for configs
--logdisk 15     # 15 GB for logs
--datadisk 150   # 150 GB for data
# Total: ~193 GB
```

#### Large Team (50+ users)
```bash
--bootdisk 30    # 30 GB for OS
--configdisk 5   # 5 GB for configs
--logdisk 20     # 20 GB for logs
--datadisk 300   # 300+ GB for data
# Total: ~355+ GB
```

### Storage Growth Factors

**Data Disk** (`/var/opt/gitlab`) grows based on:
- Number of Git repositories
- Repository sizes (code, binaries, assets)
- CI/CD artifacts and job logs
- Container registry images
- User uploads and attachments
- Database size

**Log Disk** (`/var/log/gitlab`) grows based on:
- User activity level
- CI/CD pipeline frequency
- Log retention policy
- Debug logging settings

**Config Disk** (`/etc/gitlab`) is relatively stable:
- Configuration files
- SSL certificates
- Custom scripts

**Boot Disk** (`/`) grows slowly:
- GitLab version upgrades
- System package updates
- Temporary files

### Monitoring Storage Usage

```bash
# Check all volumes
pct exec <VMID> -- df -h

# Check specific volume
pct exec <VMID> -- df -h /var/opt/gitlab

# Check largest directories
pct exec <VMID> -- du -sh /var/opt/gitlab/*

# Check repository sizes
pct exec <VMID> -- du -sh /var/opt/gitlab/git-data/repositories/*
```

### Expanding Storage

If you run out of space, you can expand LVM volumes:

```bash
# Extend the LV (add 50GB to data disk)
lvextend -L +50G /dev/pve/vm-<VMID>-gitlab-opt

# Resize the filesystem
pct exec <VMID> -- resize2fs /dev/mapper/pve-vm--<VMID>--gitlab--opt

# Verify new size
pct exec <VMID> -- df -h /var/opt/gitlab
```

### Storage Best Practices

1. **Monitor regularly** - Set up alerts for 80% disk usage
2. **Plan for growth** - Estimate 20-30% annual growth for data disk
3. **Clean up regularly** - Remove old CI/CD artifacts and logs
4. **Use backup compression** - Saves significant space
5. **Consider separate storage** - Use dedicated storage for large teams

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

### Example 1: Basic Internal GitLab Server

**Scenario**: Small team (5-10 users), internal network only

```bash
./pve-secure-gitlab-lxc.sh \
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

### Example 2: High-Performance GitLab for Development Team

**Scenario**: Medium team (20-50 users), heavy CI/CD usage

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 130 \
  --hostname gitlab-dev \
  --cpu 8 \
  --ram 16384 \
  --bootdisk 30 \
  --datadisk 200 \
  --logdisk 20 \
  --configdisk 5 \
  --ip 192.168.1.130/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.dev.company.local \
  --storage local-lvm \
  --bridge vmbr0
```

**Result**:
- Container ID: 300
- 8 CPU cores for faster CI/CD pipelines
- 16GB RAM for better performance
- 200GB data storage for large repositories
- Suitable for active development teams

---

### Example 3: Dual-Network GitLab (Internal + External)

**Scenario**: GitLab accessible from both internal network and internet

```bash
# First, create with internal network
./pve-secure-gitlab-lxc.sh \
  --vmid 140 \
  --hostname gitlab-public \
  --cpu 6 \
  --ram 12288 \
  --bootdisk 25 \
  --datadisk 150 \
  --logdisk 15 \
  --configdisk 3 \
  --ip 192.168.1.140/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.example.com \
  --storage local-lvm \
  --bridge vmbr0

# After installation, add external network interface
pct set 400 -net1 name=eth1,bridge=vmbr1,ip=203.0.113.140/24,gw=203.0.113.1,type=veth
```

**Result**:
- Container ID: 400
- Internal IP: 192.168.1.140 (vmbr0)
- External IP: 203.0.113.140 (vmbr1)
- Accessible from both networks
- Configure firewall rules for external access

---

### Example 4: Specific GitLab Version Installation

**Scenario**: Need specific GitLab version for compatibility

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 150 \
  --hostname gitlab-legacy \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.150/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab-legacy.local \
  --storage local-lvm \
  --bridge vmbr0 \
  --version 16.8.1
```

**Result**:
- Installs GitLab CE version 16.8.1 specifically
- Useful for maintaining compatibility with existing integrations
- Can upgrade later using standard GitLab upgrade procedures

---

### Example 5: Cleanup and Reinstall

**Scenario**: Previous installation failed, need to cleanup and retry

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 125 \
  --hostname gitlab-retry \
  --cpu 4 \
  --ram 8192 \
  --bootdisk 20 \
  --datadisk 100 \
  --logdisk 10 \
  --configdisk 2 \
  --ip 192.168.1.125/24 \
  --gateway 192.168.1.1 \
  --dns 8.8.8.8 \
  --url https://gitlab.example.com \
  --storage local-lvm \
  --bridge vmbr0 \
  --force-cleanup
```

**Result**:
- Automatically stops and removes existing container 110
- Removes all associated LVs (vm-110-gitlab-*)
- Performs fresh installation
- No manual cleanup required

---

### Example 6: Multiple GitLab Instances

**Scenario**: Separate GitLab instances for different departments

```bash
# Production GitLab
./pve-secure-gitlab-lxc.sh \
  --vmid 170 --hostname gitlab-prod --cpu 8 --ram 16384 \
  --bootdisk 30 --datadisk 300 --logdisk 20 --configdisk 5 \
  --ip 192.168.1.170/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab-prod.company.local --storage local-lvm --bridge vmbr0

# Development GitLab
./pve-secure-gitlab-lxc.sh \
  --vmid 180 --hostname gitlab-dev --cpu 4 --ram 8192 \
  --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \
  --ip 192.168.1.180/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab-dev.company.local --storage local-lvm --bridge vmbr0

# Testing GitLab
./pve-secure-gitlab-lxc.sh \
  --vmid 190 --hostname gitlab-test --cpu 2 --ram 4096 \
  --bootdisk 15 --datadisk 50 --logdisk 5 --configdisk 1 \
  --ip 192.168.1.190/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab-test.company.local --storage local-lvm --bridge vmbr0
```

**Result**:
- Three separate GitLab instances
- Production: High resources for critical workloads
- Development: Medium resources for active development
- Testing: Minimal resources for testing purposes
- Each instance completely isolated

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

**Version**: 1.0.0  
**Last Updated**: 2025-01-04  
**Tested On**: Proxmox VE 8.x with Ubuntu 24.04 LXC

## Changelog

See `CHANGELOG.md` for version history and changes.
