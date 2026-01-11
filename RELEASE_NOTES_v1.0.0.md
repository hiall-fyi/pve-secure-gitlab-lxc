# GitLab CE Secure Installation Script v1.0.0

Production-ready, security-hardened installation script for deploying GitLab Community Edition on Proxmox LXC containers.

## 🚀 What's New

This is the first stable release of GitLab CE Secure Installation Script - a comprehensive solution for deploying GitLab on Proxmox LXC with military-grade security standards.

### ✨ Key Features

**🔒 Security First**
- Unprivileged LXC container for enhanced isolation
- Automated system updates (host + container)
- Flexible SSL: Self-signed certificates (internal) or Let's Encrypt (public domains)
- Strong cipher suites (TLS 1.2/1.3)
- HTTPS redirect enforcement
- Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy)
- Rate limiting configuration
- UFW firewall setup
- Session management (7-day expiry)

**📦 Storage Management**
- Separate LVM volumes for better organization:
  - `/etc/gitlab` - Configuration files
  - `/var/log/gitlab` - Log files
  - `/var/opt/gitlab` - Data files
- Easy backup and snapshot management
- Storage sizing recommendations by team size

**⚙️ Flexible Deployment**
- Interactive mode for guided setup
- Non-interactive mode for automation
- Specific GitLab version installation support
- Multiple network bridge support (vmbr0, vmbr1, vmbr3, etc.)
- Intelligent cleanup of existing containers and LVs
- Fingerprint tracking for easy resource identification

**📖 Comprehensive Documentation**
- SSL configuration guide (self-signed vs Let's Encrypt)
- Storage sizing recommendations by team size
- 6 real-world usage examples
- Post-installation guide
- Management commands reference
- Troubleshooting section
- Performance tuning guide

## 📦 Installation

### Quick Start

```bash
# Download the script
wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh
chmod +x pve-secure-gitlab-lxc.sh

# Run in interactive mode
./pve-secure-gitlab-lxc.sh
```

### Requirements

- Proxmox VE 7.0 or higher
- Minimum 150GB available LVM space
- Recommended 8GB+ RAM for GitLab container
- Recommended 4+ CPU cores
- Working network configuration with internet access

### Non-Interactive Mode

**Internal deployment with self-signed certificate:**
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

**Public deployment with Let's Encrypt:**
```bash
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

## 🔧 Technical Details

- **Tested On**: Proxmox VE 8.x with Ubuntu 24.04 LXC
- **GitLab Version**: Latest stable (or specific version via `--version` parameter)
- **Container Type**: Unprivileged LXC
- **SSL Options**: Self-signed (default) or Let's Encrypt
- **Network**: Flexible bridge support (vmbr0, vmbr1, vmbr3, etc.)
- **Error Handling**: Comprehensive error handling and validation
- **Cleanup**: Automatic cleanup of failed installations

## 📚 Documentation

Full documentation available in [README.md](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/blob/main/README.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

Thanks to the open-source community and the tools that made this possible:
- GitLab Community Edition
- Proxmox VE
- Ubuntu LXC
- OpenSSL & Let's Encrypt

---

**Full Changelog**: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/blob/main/CHANGELOG.md

**Installation**: `wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh`
