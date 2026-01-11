# Release Notes - v1.1.2

**Release Date**: 2026-01-11  
**Type**: Patch Release (Bug Fix)

---

## 🐛 Bug Fix

### Fixed: Installation Summary Display Error

**Issue**: Installation completed successfully but showed error at the end:
```
/dev/fd/63: line 1256: \033[0;34mGitHub:\033[0m: command not found
```

**Cause**: EOF marker was placed incorrectly, causing GitHub and Support links to be executed as shell commands instead of being displayed.

**Fix**: Moved GitHub and Support links inside the EOF block to display correctly in installation summary.

**Impact**: This was a cosmetic issue that did not affect GitLab installation or functionality. The error message appeared after successful installation but could be confusing to users.

---

## 🔄 Upgrade from v1.1.1

**No action required** - This is a minor bug fix. Existing v1.1.1 installations work perfectly fine. The fix only affects the installation summary display for new installations.

---

## 📈 What's Changed

### Files Modified

- `pve-secure-gitlab-lxc.sh` - Fixed EOF placement in installation summary
- `CHANGELOG.md` - Added v1.1.2 entry
- `RELEASE_NOTES_v1.1.2.md` - This file

### Code Changes

- Moved GitHub and Support links inside EOF block (lines 1257-1258)
- Updated script version to 1.1.2

---

## 💬 Support

If you encounter any issues:

1. Check the [documentation](README.md)
2. Review installation logs
3. Open an issue on [GitHub](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Made with ❤️ by [@hiall-fyi](https://github.com/hiall-fyi)**

If this script saves you time, consider [buying me a coffee](https://buymeacoffee.com/hiallfyi)! ☕
