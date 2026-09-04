# Proxmox LXC GitLab CE — Secure Installation Script

<div align="center">

<!-- Platform Badges -->
![Proxmox](https://img.shields.io/badge/Proxmox-VE%208.x-E57000?style=for-the-badge&logo=proxmox&logoColor=white) ![GitLab CE](https://img.shields.io/badge/GitLab-CE-FC6D26?style=for-the-badge&logo=gitlab&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LXC-E95420?style=for-the-badge&logo=ubuntu&logoColor=white) ![Security](https://img.shields.io/badge/Security-Hardened-00C853?style=for-the-badge&logo=security&logoColor=white)

<!-- Status Badges -->
![Version](https://img.shields.io/badge/Version-2.1.1-purple?style=for-the-badge) ![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge) ![shellcheck](https://img.shields.io/badge/shellcheck-passing-brightgreen?style=for-the-badge&logo=gnu-bash&logoColor=white) ![Maintained](https://img.shields.io/badge/Maintained-Yes-green.svg?style=for-the-badge)

<!-- Community Badges -->
![GitHub stars](https://img.shields.io/github/stars/hiall-fyi/pve-secure-gitlab-lxc?style=for-the-badge&logo=github) ![GitHub forks](https://img.shields.io/github/forks/hiall-fyi/pve-secure-gitlab-lxc?style=for-the-badge&logo=github) ![GitHub issues](https://img.shields.io/github/issues/hiall-fyi/pve-secure-gitlab-lxc?style=for-the-badge&logo=github) ![GitHub last commit](https://img.shields.io/github/last-commit/hiall-fyi/pve-secure-gitlab-lxc?style=for-the-badge&logo=github)

<!-- Support -->
[![Buy Me A Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hiallfyi)

**One command — from a bare Proxmox host to a hardened GitLab CE in about 15 minutes.**

[Quick Start](#-quick-start) • [Features](#-features) • [Storage Guide](#-storage-configuration-guide) • [Troubleshooting](#-troubleshooting) • [Support](#-support)

</div>

---

## Why This Script?

The manual route is: create an unprivileged LXC, carve LVM volumes, install packages, generate SSL, harden nginx, configure UFW, then re-check every setting. Plenty of places to slip up.

This script does the same thing in one command. Answer a handful of prompts (or pass flags for automation) and you'll have a running, hardened GitLab in about 15 minutes.

- **One command** — bare Proxmox host to running GitLab
- **Hardened by default** — unprivileged container, TLS 1.2/1.3, security headers, UFW, rate limiting — all configured automatically
- **Two storage layouts** — Simple Mode (one disk, recommended) or Advanced Mode (separate volumes if you need granular snapshots or compliance separation)
- **Sensible defaults** — auto-detects VMID, gateway, and DNS, so most prompts you can just Enter through
- **Pick your SSL** — self-signed (works on internal networks straight away) or Let's Encrypt (public domains)

---

## Quick Start

**Prerequisites:** Proxmox VE 8.x, 150GB+ available LVM space, root access. Ubuntu 24.04 LXC template auto-downloads if missing.

### 1. Download

```bash
wget https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh
chmod +x pve-secure-gitlab-lxc.sh
```

### 2. Run


**Interactive Mode** (recommended for first-time users):

```bash
./pve-secure-gitlab-lxc.sh
```

**Non-Interactive — Simple Mode** (recommended):

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 50 \
  --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --pve-storage local-lvm
```

**Non-Interactive — Advanced Mode**:

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 120 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode advanced --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \
  --ip 192.168.1.120/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --pve-storage local-lvm --storage pve
```

### 3. Access GitLab

1. Visit your GitLab URL (e.g., `https://gitlab.local`)
2. Login with username `root` and the password displayed at installation completion
3. **Change the root password immediately!**

---

## Features

### What You Get

- **System updates first** — Proxmox host and the new container both get the latest patches before GitLab is installed
- **Isolated container** — GitLab runs in an unprivileged LXC, so a compromise inside it can't easily reach the host
- **Self-signed or Let's Encrypt SSL** — pick whichever fits your network
- **Version control** — install the latest stable release, or pin a specific version (e.g. `--version 16.8.1`)
- **Bridge of your choice** — `vmbr0`, `vmbr1`, `vmbr3`, whichever you've configured
- **Safe re-runs** — if a previous install failed, the script detects leftover containers / LVs and offers to clean them up
- **Sensible defaults** — auto-detects next available VMID, gateway, and DNS

### Security (configured automatically)

- **Unprivileged container** — UID-mapped, kernel-isolated
- **TLS 1.2 / 1.3 only** — older protocols disabled
- **HTTPS enforced** — HTTP requests redirect to HTTPS
- **Security headers** — HSTS, X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy
- **Rate limiting** — brute-force login attempts are throttled
- **UFW firewall** — only 22 / 80 / 443 are open; everything else is closed

### Storage

- **Simple Mode** (default) — single root filesystem. One disk to monitor, one volume to expand. Recommended for most setups.
- **Advanced Mode** — separate LVM volumes for `/etc/gitlab`, `/var/log/gitlab`, `/var/opt/gitlab`. Useful if you need per-volume snapshots or compliance separation.

---

## Storage Configuration Guide

### Two storage flags, two different things

Proxmox keeps these in separate namespaces, and the script needs both kept apart:

- **`--pve-storage`** — a Proxmox **storage ID**, the kind `pvesm status` lists (`local-lvm`, `local-zfs`, ...). The container's root disk lives here. Defaults to `local-lvm`, which is what a stock Proxmox install ships. Used in both modes.
- **`--storage`** — an LVM **volume-group name**, the kind `vgs` lists (usually `pve`). Only Advanced Mode uses it, for the separate `/etc`, `/var/log`, `/var/opt` volumes. Leave it out in Simple Mode.

On a default install `local-lvm` is backed by the volume group `pve`, but the two names are not interchangeable. `pve` is not a storage ID, and `local-lvm` is not a volume group. If you're unsure, run `pvesm status` for the first and `vgs` for the second.

### Quick Comparison

| Feature | Simple Mode ⭐ | Advanced Mode |
|---------|---------------|---------------|
| **Complexity** | Low | Medium |
| **Setup** | 1 parameter | 4 parameters |
| **Management** | Easy | Requires planning |
| **Flexibility** | High (auto-sharing) | Medium (fixed sizes) |
| **Backup** | Single snapshot | Multiple snapshots |
| **Best For** | 90% of users | Enterprise/Compliance |

**Recommendation**: Start with Simple Mode. You can always migrate to Advanced Mode later.

### Sizing Recommendations

**Simple Mode:**

| Team Size | Recommended Size | Use Case |
|-----------|------------------|----------|
| 1-10 users | 30-50 GB | Small team, light usage |
| 10-50 users | 50-100 GB | Medium team, moderate CI/CD |
| 50+ users | 100-200+ GB | Large team, heavy CI/CD |

**Advanced Mode:**

| Team Size | Boot | Config | Logs | Data | Total |
|-----------|------|--------|------|------|-------|
| 1-10 users | 20G | 2G | 10G | 50G | 82G |
| 10-50 users | 25G | 3G | 15G | 150G | 193G |
| 50+ users | 30G | 5G | 20G | 300G | 355G |

<details>
<summary><strong>Monitoring & Expanding Storage</strong></summary>

**Simple Mode:**

```bash
# Check total usage
pct exec <VMID> -- df -h /

# Expand (add 50GB)
pct stop <VMID>
lvextend -L +50G /dev/pve/vm-<VMID>-disk-0
e2fsck -f /dev/pve/vm-<VMID>-disk-0
resize2fs /dev/pve/vm-<VMID>-disk-0
pct start <VMID>
```

**Advanced Mode:**

```bash
# Check all volumes
pct exec <VMID> -- df -h

# Expand data volume (add 50GB)
lvextend -L +50G /dev/pve/vm-<VMID>-gitlab-opt
pct exec <VMID> -- resize2fs /dev/mapper/pve-vm--<VMID>--gitlab--opt
```

</details>

<details>
<summary><strong>Migration: Advanced → Simple</strong></summary>

⚠️ **Backup first!**

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
pct stop <VMID>
lvextend -L +15G /dev/pve/vm-<VMID>-disk-0
e2fsck -f /dev/pve/vm-<VMID>-disk-0
resize2fs /dev/pve/vm-<VMID>-disk-0
pct start <VMID>
```

</details>

<details>
<summary><strong>Cleanup Commands</strong></summary>

```bash
# Clean old CI/CD artifacts (older than 30 days)
pct exec <VMID> -- gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# Clean old logs
pct exec <VMID> -- gitlab-ctl cleanup-logs

# Clean old backups (older than 7 days)
pct exec <VMID> -- find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete
```

</details>

---

## SSL Certificate Configuration

### Self-Signed (Default)

Best for internal networks, development, testing. Works immediately, no domain registration needed, 10-year validity.

```bash
./pve-secure-gitlab-lxc.sh ... --ssl-type self-signed
# or simply omit --ssl-type (self-signed is default)
```

### Let's Encrypt

For public-facing instances. Needs a valid public domain and ports 80 / 443 reachable from the internet. The contact email is used for certificate-expiry warnings.

```bash
./pve-secure-gitlab-lxc.sh ... \
  --url https://gitlab.example.com \
  --ssl-type letsencrypt \
  --le-email you@example.com
```

<details>
<summary><strong>Let's Encrypt Troubleshooting</strong></summary>

```bash
# Check certificate status
pct exec <VMID> -- gitlab-ctl status

# View Let's Encrypt logs
pct exec <VMID> -- cat /var/log/gitlab/nginx/error.log

# Manually trigger certificate renewal
pct exec <VMID> -- gitlab-ctl renew-le-certs
```

</details>

---

## Usage Examples

<details>
<summary><strong>Small Team — Simple Mode (5-10 users)</strong></summary>

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 50 \
  --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --pve-storage local-lvm
```

</details>

<details>
<summary><strong>Medium Team — Simple Mode (20-50 users)</strong></summary>

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 120 --hostname gitlab-dev --cpu 6 --ram 12288 \
  --storage-mode simple --rootfs-size 100 \
  --ip 192.168.1.120/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.dev.local --pve-storage local-lvm
```

</details>

<details>
<summary><strong>Enterprise — Advanced Mode (compliance requirements)</strong></summary>

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 130 --hostname gitlab-prod --cpu 8 --ram 16384 \
  --storage-mode advanced --bootdisk 30 --datadisk 300 --logdisk 20 --configdisk 5 \
  --ip 192.168.1.130/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.company.com --pve-storage local-lvm --storage pve
```

</details>

<details>
<summary><strong>Public Deployment with Let's Encrypt</strong></summary>

```bash
./pve-secure-gitlab-lxc.sh \
  --vmid 150 --hostname gitlab --cpu 4 --ram 8192 \
  --storage-mode simple --rootfs-size 100 \
  --ip 203.0.113.150/24 --gateway 203.0.113.1 --dns 8.8.8.8 \
  --url https://gitlab.example.com --pve-storage local-lvm \
  --ssl-type letsencrypt --le-email you@example.com
```

</details>

<details>
<summary><strong>v1.0.0 Compatibility (existing automation scripts)</strong></summary>

```bash
# Old v1.0.0 command still works — automatically uses Advanced Mode.
# --storage is your LVM volume group (vgs); the rootfs defaults to the local-lvm storage ID.
./pve-secure-gitlab-lxc.sh \
  --vmid 140 --hostname gitlab --cpu 4 --ram 8192 \
  --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \
  --ip 192.168.1.140/24 --gateway 192.168.1.1 --dns 8.8.8.8 \
  --url https://gitlab.local --storage pve
```

</details>

---

## Post-Installation

### First Login

1. Open your GitLab URL in a browser
2. Login with username **root** and the password shown at the end of the installation
3. **Change the root password immediately** — the initial password is also written to `/var/log/gitlab-ce-install-<VMID>.log` (mode 0600, root-only), but treat it as temporary regardless

### What to Do Next

1. **Change Root Password** — click your avatar (top-right) → Edit Profile → Password
2. **Enable 2FA** — Edit Profile → Account → Two-Factor Authentication
3. **Create your first users** — Admin Area (wrench icon) → Users → New User
4. **Add SSH keys** — Edit Profile → SSH Keys — so you can push/pull without typing passwords

### Self-Signed Certificate — Browser Warning

Your browser will show a security warning. This is normal for self-signed certificates.

- **Quick**: Click "Advanced" → "Proceed to site"
- **Proper**: Add certificate to trusted store:

```bash
pct exec <VMID> -- cat /etc/gitlab/ssl/<hostname>.crt > gitlab.crt
# macOS
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain gitlab.crt
# Linux
sudo cp gitlab.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates
```

### Self-Signed Certificate — GitLab Runner

Registering a Runner against a self-signed install fails until the Runner trusts the certificate too — this is separate from the browser trust step above.

```bash
pct exec <VMID> -- cat /etc/gitlab/ssl/<hostname>.crt > gitlab.crt
sudo cp gitlab.crt /etc/gitlab-runner/certs/<hostname>.crt
sudo gitlab-runner restart
```

For a Docker-executor Runner, the build containers don't pick this up automatically — see [GitLab's self-signed certificate docs](https://docs.gitlab.com/runner/configuration/tls-self-signed/) for mounting it into the job container.

---

## Version Management

You can pin a specific GitLab version during installation, or upgrade later inside the container:

```bash
# Install a specific version
./pve-secure-gitlab-lxc.sh --vmid 110 ... --version 16.8.1

# Upgrade GitLab later
pct enter <VMID>
gitlab-backup create          # always backup first!
apt update
apt upgrade gitlab-ce         # or pin: apt install gitlab-ce=16.9.0-ce.0
gitlab-ctl reconfigure
gitlab-ctl restart
```

---

## Management Commands

<details>
<summary><strong>GitLab Service Management</strong></summary>

```bash
pct exec <VMID> -- gitlab-ctl status          # Check all services
pct exec <VMID> -- gitlab-ctl restart         # Restart all services
pct exec <VMID> -- gitlab-ctl reconfigure     # Reconfigure GitLab
pct exec <VMID> -- gitlab-ctl tail            # View live logs
pct exec <VMID> -- gitlab-ctl tail nginx      # View specific service logs
```

</details>

<details>
<summary><strong>Container Management</strong></summary>

```bash
pct enter <VMID>              # Enter container
pct status <VMID>             # Check status
pct stop <VMID>               # Stop
pct start <VMID>              # Start
pct reboot <VMID>             # Reboot
pct exec <VMID> -- df -h      # Check disk usage
pct exec <VMID> -- free -h    # Check memory usage
```

</details>

<details>
<summary><strong>Backup and Restore</strong></summary>

```bash
# Manual backup
pct exec <VMID> -- gitlab-backup create

# List backups
pct exec <VMID> -- ls -lh /var/opt/gitlab/backups/

# Restore
pct exec <VMID> -- gitlab-ctl stop puma
pct exec <VMID> -- gitlab-ctl stop sidekiq
pct exec <VMID> -- gitlab-backup restore BACKUP=<timestamp>
pct exec <VMID> -- gitlab-ctl restart
pct exec <VMID> -- gitlab-rake gitlab:check SANITIZE=true

# Automated daily backup (add to crontab inside container)
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1
0 3 * * * find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete
```

</details>

<details>
<summary><strong>Identifying Script-Created Resources</strong></summary>

```bash
pct list | grep -i gitlab                              # List containers
pct config <VMID> | grep description                   # Check fingerprint
lvs -o lv_name,lv_tags | grep gitlab-ce-secure-install # List tagged LVs
```

</details>

---

## Performance Tuning

If GitLab feels slow, you can tune resource allocation. Enter the container and edit `/etc/gitlab/gitlab.rb`:

| Team Size | shared_buffers | max_concurrency | worker_processes | What it helps |
|-----------|---------------|-----------------|------------------|---------------|
| < 10 users | 256MB | 10 | 2 | Default — good for small teams |
| 10-50 users | 512MB | 20 | 4 | Faster CI/CD and page loads |
| > 50 users | 1GB | 30 | 8 | Heavy usage with many concurrent users |

After changes: `gitlab-ctl reconfigure && gitlab-ctl restart`

---

## Troubleshooting

<details>
<summary><strong>GitLab service won't start</strong></summary>

```bash
pct exec <VMID> -- gitlab-ctl tail
pct exec <VMID> -- gitlab-rake gitlab:check
pct exec <VMID> -- gitlab-ctl reconfigure
```

</details>

<details>
<summary><strong>Cannot access GitLab</strong></summary>

```bash
pct exec <VMID> -- ufw status
pct exec <VMID> -- gitlab-ctl status nginx
pct exec <VMID> -- ls -l /etc/gitlab/ssl/
```

</details>

<details>
<summary><strong>Out of memory</strong></summary>

```bash
pct set <VMID> -memory 16384
pct reboot <VMID>
```

</details>

<details>
<summary><strong>Disk space issues</strong></summary>

```bash
pct exec <VMID> -- df -h
pct exec <VMID> -- gitlab-ctl cleanup-logs
pct exec <VMID> -- find /var/opt/gitlab/backups/ -name "*.tar" -mtime +7 -delete
```

</details>

<details>
<summary><strong>Reset root password</strong></summary>

```bash
pct enter <VMID>
gitlab-rails console
# In console:
user = User.find_by(username: 'root')
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save!
exit
```

</details>

For other issues, check the installation log at `/var/log/gitlab-ce-install-<VMID>.log` or [open an issue on GitHub](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues).

---

## Keeping Your GitLab Secure

The script handles the install-time hardening, but a few things you'll need to do yourself:

- **Change the root password right after install** — the initial password is shown in the terminal and saved (root-only) to `/var/log/gitlab-ce-install-<VMID>.log`
- **Turn on 2FA for all users** — especially admin accounts
- **Use SSH keys** — disable password-based Git access when possible
- **Keep things updated** — run `apt upgrade gitlab-ce` inside the container quarterly, and update host packages monthly
- **Set up automated backups** — see the Backup and Restore section above. A daily backup with 7-day retention is a good starting point
- **Restrict network access** — if your GitLab is internal-only, consider limiting access to your LAN IP range in the firewall

---

## Resources

- [GitLab Official Documentation](https://docs.gitlab.com/)
- [GitLab CE Installation Guide](https://about.gitlab.com/install/)
- [Proxmox LXC Documentation](https://pve.proxmox.com/wiki/Linux_Container)
- [GitLab Backup and Restore](https://docs.gitlab.com/ee/raketasks/backup_restore.html)

---

## Support

1. Check installation log: `/var/log/gitlab-ce-install-<VMID>.log`
2. Check GitLab logs: `pct exec <VMID> -- gitlab-ctl tail`
3. Check container logs: `pct exec <VMID> -- journalctl -xe`
4. [Open an issue on GitHub](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues)

---

## License

**MIT License** — Free to use, modify, and distribute. See [LICENSE](LICENSE) for full details.

**Made with ❤️ by Joe Yiu ([@hiall-fyi](https://github.com/hiall-fyi))**

---

## Contributing

Contributions welcome!

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Bug reports and testing count too. Everyone who's helped shape a release is listed in [CREDITS.md](CREDITS.md).

---

<details>
<summary><strong>Disclaimer</strong></summary>

This project is not affiliated with, endorsed by, or connected to GitLab Inc. or Proxmox Server Solutions GmbH. GitLab and the GitLab logo are registered trademarks of GitLab Inc. Proxmox and the Proxmox logo are registered trademarks of Proxmox Server Solutions GmbH.

This script is provided "as is" without warranty of any kind. Use at your own risk.

</details>
