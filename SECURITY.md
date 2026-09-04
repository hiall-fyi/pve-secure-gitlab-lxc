# Security Policy

## Supported Versions

This is a one-shot installer script, not a versioned application with long-term support branches. Security fixes land in the latest release only, so always run the current version from the [Releases page](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/releases) or `main`.

## Reporting a Vulnerability

**Please don't open a public issue for a security vulnerability.** Use GitHub's private reporting instead: go to the [Security tab](https://github.com/hiall-fyi/pve-secure-gitlab-lxc/security) and click **Report a vulnerability**. This keeps the details private until a fix is out.

Since this script runs as root and builds commands that execute inside the LXC container it creates, the most relevant class of bug is anything that lets a flag value or interactive prompt answer run as shell syntax rather than plain text. If you've found something like that, a private report is the right way to bring it up.
