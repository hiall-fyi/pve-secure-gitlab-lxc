# 📦 How to Create GitHub Release v1.0.0

## ✅ Completed Steps

1. ✅ Created `CHANGELOG.md` (matching proxmox-cleanup format)
2. ✅ Created `RELEASE_NOTES_v1.0.0.md` (matching proxmox-cleanup format)
3. ✅ Committed and pushed to GitHub
4. ✅ Created git tag `v1.0.0`
5. ✅ Pushed tag to GitHub

---

## 🚀 Next Steps - Create GitHub Release

### Using GitHub Web Interface

1. **Go to your repository**:
   ```
   https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases
   ```

2. **Click "Draft a new release"**

3. **Fill in the release form**:
   - **Choose a tag**: Select `v1.0.0` (already created)
   - **Release title**: `v1.0.0`
   - **Description**: Copy content from `RELEASE_NOTES_v1.0.0.md`
   - **Set as latest release**: ✅ Check this box

4. **Attach the script file** (optional but recommended):
   - Click "Attach binaries by dropping them here or selecting them"
   - Upload `pve-secure-gitlab-lxc.sh`

5. **Click "Publish release"**

---

## 📝 Release Notes Preview

The release notes follow the same format as proxmox-cleanup:

```markdown
# GitLab CE Secure Installation Script v1.0.0

Production-ready, security-hardened installation script for deploying 
GitLab Community Edition on Proxmox LXC containers.

## What's New

### Added
- Initial release of GitLab CE Secure Installation Script for Proxmox LXC
- Automated system updates for both Proxmox host and container
- Unprivileged LXC container deployment for enhanced security
[... see RELEASE_NOTES_v1.0.0.md for full content ...]
```

---

## 🔗 Quick Links

- **Repository**: https://github.com/hiall-fyi/pve-secure-gitlab-lxc
- **Releases Page**: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases
- **Tag v1.0.0**: https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases/tag/v1.0.0
- **Raw Script**: https://raw.githubusercontent.com/hiall-fyi/pve-secure-gitlab-lxc/main/pve-secure-gitlab-lxc.sh

---

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**
