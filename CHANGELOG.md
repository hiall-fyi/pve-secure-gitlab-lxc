# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-04

### 🎉 Initial Release

First stable release of GitLab CE Secure Installation Script for Proxmox LXC.

### ✨ Features

#### Core Functionality
- **Automated System Updates** - Ensures both Proxmox host and container are fully updated
- **Unprivileged Container** - Deploys GitLab in a secure, unprivileged LXC container
- **Flexible SSL Configuration** - Choose between self-signed (internal) or Let's Encrypt (public)
- **Security Hardening** - Comprehensive security configurations
- **Version Control** - Install latest stable or specific GitLab version
- **Network Flexibility** - Support for multiple network bridges (vmbr0, vmbr1, vmbr3, etc.)
- **Auto Cleanup** - Intelligent cleanup of existing containers and LVs
- **Fingerprint Tracking** - Easy identification of script-created resources

#### Security Features
- 🔒 Unprivileged LXC container for enhanced isolation
- 🔒 Forced system updates (host + container)
- 🔒 **Flexible SSL**: Self-signed certificates (internal) or Let's Encrypt (public domains)
- 🔒 Strong cipher suites (TLS 1.2/1.3)
- 🔒 HTTPS redirect enforcement
- 🔒 Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy)
- 🔒 Rate limiting configuration
- 🔒 UFW firewall setup
- 🔒 Session management

#### Storage Architecture
- 📦 Separate LVM volumes for better management:
  - `/etc/gitlab` - Configuration files
  - `/var/log/gitlab` - Log files
  - `/var/opt/gitlab` - Data files
- 📦 LVM tags for easy identification
- 📦 Easy backup and snapshot management

### 📖 Documentation

- Comprehensive README with usage examples
- SSL configuration guide (self-signed vs Let's Encrypt)
- Storage sizing recommendations by team size
- Post-installation guide
- Management commands reference
- Troubleshooting section
- Performance tuning guide

### 🔧 Technical Details

- **Tested On**: Proxmox VE 8.x with Ubuntu 24.04 LXC
- **GitLab Version**: Latest stable (or specific version via `--version` parameter)
- **Container Type**: Unprivileged LXC
- **SSL Options**: Self-signed (default) or Let's Encrypt
- **Network**: Flexible bridge support (vmbr0, vmbr1, vmbr3, etc.)

### 📝 Usage Modes

#### Interactive Mode
```bash
./pve-secure-gitlab-lxc.sh
```

#### Non-Interactive Mode
```bash
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
```

### 🙏 Credits

Created by **Joe Yiu @ hiall-fyi**

- GitHub: [@hiall-fyi](https://github.com/hiall-fyi)
- Support: [Buy Me a Coffee](https://buymeacoffee.com/hiallfyi)

---

[1.0.0]: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases/tag/v1.0.0
