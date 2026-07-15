# Credits

pve-secure-gitlab-lxc is shaped by the people who run it and take the time to report what breaks, suggest what's missing, and test the fixes. This page recognises them.

---

## ☕ Supporters

If the script saved you an afternoon of Proxmox and GitLab wrangling, a coffee is always appreciated: [Buy Me a Coffee](https://buymeacoffee.com/hiallfyi). Supporters are credited here.

---

## Per-Version Credits

Community contributors who helped shape each release through bug reports, feature requests, testing, and feedback.

### v2.1.0

- **[@lochowa](https://github.com/lochowa)** — Traced the fresh-install failure to its root in one pass ([#1](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/issues/1)): the script handed the LVM volume-group name to `pct create`, which expects a Proxmox storage ID, so a default `pve` / `local-lvm` setup could never create the container's root disk. He pinned the exact two lines that disagreed, explained why a single variable couldn't serve both namespaces, and proposed the two-variable split the fix now uses. Also offered to open the PR himself.

---

## 🌟 Special Thanks

**Everyone** who tried the script, opened an issue, or passed along a fix. Every report makes the next install smoother.

---

**Made with ❤️ by the pve-secure-gitlab-lxc community**
