# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-01-11

### Improved
- **Interactive Mode UX** - Added smart defaults for all configuration parameters
- Auto-detect next available VMID using Proxmox API
- Auto-detect default gateway and DNS from system configuration
- Auto-generate GitLab URL based on container IP
- All parameters now have sensible defaults - just press Enter to accept
- Only Container IP requires manual input (environment-specific)

### Changed
- Container ID: Auto-detects next available VMID (default)
- Container Name: `gitlab` (default)
- CPU Cores: `4` (default)
- RAM: `8192` MB (default)
- Root Filesystem Size: `50` GB for Simple Mode (default)
- Gateway: Auto-detected from system (default)
- DNS: Uses gateway IP or `8.8.8.8` (default)
- GitLab URL: Auto-generated from container IP (default)
- LVM Storage VG Name: `pve` (default)
- Network Bridge: `vmbr0` (default)

### Fixed
- **SSL Certificate Bug** - Fixed typo in openssl command (`days 3650 \\ 3650` → `days 3650`)
- **SSL/HTTP Mismatch** - Auto-adjust SSL_TYPE based on URL protocol (http:// → none, https:// → self-signed)
- **Missing SSL Certificates** - Prevented SSL config being applied to HTTP URLs
- Confusing prompts that appeared to have defaults but didn't
- Users had to manually type all values even for standard configurations
- No indication of recommended values for first-time users

### User Experience
- Installation time reduced significantly (fewer keystrokes)
- Clearer prompts showing `(default: value)` format
- Better first-time user experience with sensible defaults
- Advanced users can still override any default value
- Automatic SSL configuration based on URL protocol

## [1.1.0] - 2026-01-11

### Added
- **Simple Storage Mode (Default)** - Single root filesystem for easier management
- **Advanced Storage Mode** - Separate LVM volumes for granular control (previous default)
- Storage mode selection in interactive mode with clear recommendations
- `--storage-mode` parameter for non-interactive installations
- `--rootfs-size` parameter for Simple Mode
- Improved storage sizing recommendations based on team size
- Banner warnings about Advanced Mode complexity
- Migration guide from Advanced to Simple mode

### Changed
- **Default storage mode changed from Advanced to Simple** (breaking change for automation)
- Improved help text with storage mode explanations
- Updated examples to showcase Simple Mode first
- Reorganized README with storage mode comparison section

### Fixed
- Over-provisioned storage in separate volumes
- Difficulty redistributing space between volumes
- Unnecessary complexity for small/medium deployments

### Deprecated
- None (Advanced Mode still fully supported)

### Technical Details
- Simple Mode: Single root filesystem, all GitLab data on root
- Advanced Mode: Separate LVM volumes for /etc/gitlab, /var/log/gitlab, /var/opt/gitlab
- Backward compatibility: v1.0.0 parameters automatically trigger Advanced Mode
- Based on real-world consolidation experience (20G + 4.8G separate → 24G unified)

### Migration
- Existing v1.0.0 installations continue to work unchanged
- Users can manually consolidate to Simple Mode (see migration guide)
- New installations default to Simple Mode (recommended)

## [1.0.0] - 2025-01-04

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
- Comprehensive README with usage examples
- SSL configuration guide (self-signed vs Let's Encrypt)
- Storage sizing recommendations by team size
- Post-installation guide
- Management commands reference
- Troubleshooting section
- Performance tuning guide

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

### Installation
- One-line download: `wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh`
- Interactive mode for guided setup
- Non-interactive mode for automation
- Automatic Ubuntu 24.04 template download if missing
- Automatic cleanup of failed installations

[1.0.0]: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases/tag/v1.0.0
