# GitLab CE Secure Installation Script v1.0.0

Production-ready, security-hardened installation script for deploying GitLab Community Edition on Proxmox LXC containers.

## What's New

### Added
- Initial release of GitLab CE Secure Installation Script for Proxmox LXC
- Automated system updates for both Proxmox host and container
- Unprivileged LXC container deployment for enhanced security
- Flexible SSL configuration (self-signed or Let's Encrypt)
- Interactive and non-interactive installation modes
- Specific GitLab version installation support
- Multiple network bridge support (vmbr0, vmbr1, vmbr3, etc.)
- Intelligent cleanup of existing containers and LVs
- Fingerprint tracking for easy resource identification
- Separate LVM volumes for config, logs, and data
- Security hardening configuration (TLS 1.2/1.3, security headers, rate limiting)
- UFW firewall setup with SSH, HTTP, HTTPS rules
- Comprehensive documentation and usage examples

### Features
- **Automated Updates**: Ensures both Proxmox host and container are fully updated
- **Security First**: Unprivileged container, strong ciphers, security headers, rate limiting
- **Flexible SSL**: Self-signed certificates (internal) or Let's Encrypt (public domains)
- **Storage Management**: Separate LVM volumes for better organization and backup
- **Version Control**: Install latest stable or specific GitLab version
- **Network Flexibility**: Support for multiple network bridges
- **Auto Cleanup**: Intelligent cleanup with force-cleanup option
- **Easy Identification**: Fingerprint tracking in container notes

### Technical Details
- Bash script with comprehensive error handling
- Tested on Proxmox VE 8.x with Ubuntu 24.04 LXC
- GitLab CE (latest stable or specific version)
- Unprivileged LXC container
- TLS 1.2/1.3 with strong cipher suites
- HTTPS redirect enforcement
- Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy)
- Rate limiting configuration
- UFW firewall integration
- Session management (7-day expiry)  

## Installation

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

## Documentation

Full documentation available in [README.md](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/blob/main/README.md):

- SSL Configuration Guide (Self-Signed vs Let's Encrypt)
- Storage Sizing Recommendations by Team Size
- Usage Examples for Different Scenarios
- Post-Installation Guide
- Management Commands Reference
- Troubleshooting Section
- Performance Tuning Guide

## Changelog

See [CHANGELOG.md](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/blob/main/CHANGELOG.md) for detailed version history.

---

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**

If this script saved you time and effort, consider [buying me a coffee](https://buymeacoffee.com/hiallfyi)!
