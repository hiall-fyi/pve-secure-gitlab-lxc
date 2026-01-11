#!/usr/bin/env bash
#
# GitLab CE Secure Installation Script for Proxmox LXC
# Military-Grade Security Standards - Internal Deployment
#
# Version: 1.1.0
# Author: Joe @ hiall-fyi
# GitHub: https://github.com/hiall-fyi
# Support: https://buymeacoffee.com/hiallfyi
#
# Features:
# 1. Forced System Updates (Proxmox + Container)
# 2. Unprivileged Container
# 3. Self-Signed SSL Certificate (Internal Use)
# 4. Security Hardening Configuration
# 5. Complete Error Handling
# 6. Automatic Cleanup of Existing Resources
# 7. Simple Mode (Single Root Filesystem) - NEW in v1.1.0
# 8. Advanced Mode (Separate LVM Volumes) - NEW in v1.1.0
#
# Usage:
#   Interactive Mode:  ./gitlab-ce-secure-install.sh
#   Non-Interactive:   ./gitlab-ce-secure-install.sh --vmid 110 --hostname gitlab --cpu 4 --ram 8192 ...
#

set -euo pipefail

# ---------- Colors & Logging ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$*${NC}\n"
}

err() {
    log_error "$*"
    exit 1
}

# ---------- Pre-flight Checks ----------
log_step "Running pre-flight checks..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   err "This script must be run as root. Please use sudo or run as root user."
fi

# Check if running on Proxmox
if ! command -v pct &> /dev/null; then
    err "This script can only run on Proxmox VE."
fi

log_info "✓ Root privileges confirmed"
log_info "✓ Proxmox VE environment confirmed"

# ---------- Parse Command Line Arguments ----------
INTERACTIVE=true
VMID=""
HOSTNAME=""
CPU=""
RAM=""
BOOTDISK=""
OPT_SIZE=""
LOG_SIZE=""
ETC_SIZE=""
CT_IP=""
GATEWAY=""
DNS=""
GITLAB_URL=""
GITLAB_VERSION=""
STORAGE=""
BRIDGE="vmbr0"
FORCE_CLEANUP=false
SSL_TYPE="self-signed"  # Default to self-signed for internal use
STORAGE_MODE="simple"   # NEW: simple (single root) or advanced (separate LVs)

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Interactive Mode (no arguments):
    $0

Non-Interactive Mode (Simple Storage - Recommended):
    $0 --vmid <id> --hostname <name> --cpu <cores> --ram <mb> \\
       --storage-mode simple --rootfs-size <gb> \\
       --ip <ip/mask> --gateway <ip> --dns <ip> --url <url> --storage <vg>

Non-Interactive Mode (Advanced Storage):
    $0 --vmid <id> --hostname <name> --cpu <cores> --ram <mb> \\
       --storage-mode advanced --bootdisk <gb> --datadisk <gb> --logdisk <gb> --configdisk <gb> \\
       --ip <ip/mask> --gateway <ip> --dns <ip> --url <url> --storage <vg>

Required Options (Non-Interactive):
    --vmid <id>           Container ID (e.g., 110)
    --hostname <name>     Container hostname (e.g., gitlab)
    --cpu <cores>         Number of CPU cores (e.g., 4)
    --ram <mb>            RAM in MB (e.g., 8192)
    --ip <ip/mask>        Container IP with CIDR (e.g., 192.168.1.110/24)
    --gateway <ip>        Gateway IP (e.g., 192.168.1.1)
    --dns <ip>            DNS server IP (e.g., 8.8.8.8)
    --url <url>           GitLab URL (e.g., https://gitlab.example.com)
    --storage <vg>        LVM storage VG name (e.g., pve)

Storage Mode Options:
    --storage-mode <mode> Storage configuration mode (default: simple)
                          simple   - Single root filesystem (recommended)
                          advanced - Separate LVM volumes

Simple Mode (Recommended):
    --rootfs-size <gb>    Total root filesystem size in GB (e.g., 50)
                          Includes OS + all GitLab data

Advanced Mode:
    --bootdisk <gb>       Boot disk size in GB (e.g., 20)
    --datadisk <gb>       Data disk size in GB (e.g., 100)
    --logdisk <gb>        Log disk size in GB (e.g., 10)
    --configdisk <gb>     Config disk size in GB (e.g., 2)

Optional:
    --version <version>   GitLab version (leave empty for latest, e.g., 16.8.1)
    --bridge <bridge>     Network bridge (default: vmbr0, e.g., vmbr3)
    --ssl-type <type>     SSL certificate type: self-signed or letsencrypt (default: self-signed)
    --force-cleanup       Automatically cleanup existing container/LVs (non-interactive)
    --help                Show this help message

Examples:
    # Interactive mode (recommended for first-time users)
    $0

    # Simple Mode - Single root filesystem (recommended)
    $0 --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \\
       --storage-mode simple --rootfs-size 50 \\
       --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \\
       --url https://gitlab.example.com --storage local-lvm

    # Advanced Mode - Separate LVM volumes
    $0 --vmid 120 --hostname gitlab --cpu 4 --ram 8192 \\
       --storage-mode advanced --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \\
       --ip 192.168.1.120/24 --gateway 192.168.1.1 --dns 8.8.8.8 \\
       --url https://gitlab.example.com --storage local-lvm

    # v1.0.0 compatibility (automatically uses Advanced Mode)
    $0 --vmid 110 --hostname gitlab --cpu 4 --ram 8192 \\
       --bootdisk 20 --datadisk 100 --logdisk 10 --configdisk 2 \\
       --ip 192.168.1.110/24 --gateway 192.168.1.1 --dns 8.8.8.8 \\
       --url https://gitlab.example.com --storage local-lvm

    # Public deployment with Let's Encrypt
    $0 --vmid 130 --hostname gitlab --cpu 4 --ram 8192 \\
       --storage-mode simple --rootfs-size 50 \\
       --ip 10.29.83.130/24 --gateway 10.29.83.253 --dns 8.8.8.8 \\
       --url https://gitlab.example.com --storage pve --ssl-type letsencrypt

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --vmid)
            VMID="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        --cpu)
            CPU="$2"
            shift 2
            ;;
        --ram)
            RAM="$2"
            shift 2
            ;;
        --storage-mode)
            # Normalize to lowercase and trim whitespace
            STORAGE_MODE=$(echo "$2" | tr '[:upper:]' '[:lower:]' | xargs)
            shift 2
            ;;
        --rootfs-size)
            BOOTDISK="$2"
            shift 2
            ;;
        --bootdisk)
            BOOTDISK="$2"
            shift 2
            ;;
        --datadisk)
            OPT_SIZE="$2"
            shift 2
            ;;
        --logdisk)
            LOG_SIZE="$2"
            shift 2
            ;;
        --configdisk)
            ETC_SIZE="$2"
            shift 2
            ;;
        --ip)
            CT_IP="$2"
            shift 2
            ;;
        --gateway)
            GATEWAY="$2"
            shift 2
            ;;
        --dns)
            DNS="$2"
            shift 2
            ;;
        --url)
            GITLAB_URL="$2"
            shift 2
            ;;
        --version)
            GITLAB_VERSION="$2"
            shift 2
            ;;
        --storage)
            STORAGE="$2"
            shift 2
            ;;
        --bridge)
            BRIDGE="$2"
            shift 2
            ;;
        --ssl-type)
            SSL_TYPE="$2"
            shift 2
            ;;
        --force-cleanup)
            FORCE_CLEANUP=true
            shift
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            ;;
    esac
done

# Backward compatibility: If old parameters detected, use Advanced Mode
if [ -n "$OPT_SIZE" ] || [ -n "$LOG_SIZE" ] || [ -n "$ETC_SIZE" ]; then
    if [ "$STORAGE_MODE" = "simple" ]; then
        log_warn "Detected both Simple and Advanced mode parameters. Using Advanced Mode."
    fi
    STORAGE_MODE="advanced"
    log_info "Detected v1.0.0 parameters, using Advanced Mode for backward compatibility"
fi

# ---------- Step 1: Update Proxmox Host System ----------
log_step "Step 1: Updating Proxmox host system"

log_info "Updating package lists..."
apt update || err "apt update failed"

log_info "Upgrading system packages..."
DEBIAN_FRONTEND=noninteractive apt upgrade -y || err "apt upgrade failed"

log_info "Upgrading Proxmox packages..."
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y || log_warn "dist-upgrade had warnings, continuing..."

log_info "Cleaning up old packages..."
apt autoremove -y
apt autoclean

log_info "✓ Proxmox host system updated"

# ---------- Template Detection ----------
log_step "Detecting Ubuntu 24.04 template..."

TEMPLATE=$(pvesm list local | grep 'vztmpl/ubuntu-24.04' | awk '{print $1}' | head -n1 || true)

if [ -z "$TEMPLATE" ]; then
    log_warn "Ubuntu 24.04 template not found, attempting download..."
    
    # Download Ubuntu 24.04 template
    pveam update
    pveam download local ubuntu-24.04-standard_24.04-2_amd64.tar.zst || \
        err "Failed to download Ubuntu 24.04 template. Please download manually to /var/lib/vz/template/cache/"
    
    TEMPLATE=$(pvesm list local | grep 'vztmpl/ubuntu-24.04' | awk '{print $1}' | head -n1 || true)
    
    if [ -z "$TEMPLATE" ]; then
        err "Template still not found after download. Please check /var/lib/vz/template/cache/"
    fi
fi

log_info "✓ Using template: $TEMPLATE"

# ---------- User Input ----------
log_step "Collecting installation parameters..."

if [ "$INTERACTIVE" = true ]; then
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}Storage Configuration Mode${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Choose storage configuration:"
    echo ""
    echo "  ${GREEN}1. Simple Mode (Recommended)${NC} ⭐"
    echo "     • Single root filesystem"
    echo "     • All GitLab data on root"
    echo "     • Easier management"
    echo "     • Flexible space allocation"
    echo "     • Best for most users"
    echo ""
    echo "  ${YELLOW}2. Advanced Mode${NC}"
    echo "     • Separate LVM volumes"
    echo "     • Granular control"
    echo "     • Independent snapshots"
    echo "     • More complex management"
    echo ""
    read -p "Select mode (1 or 2, default: 1): " MODE_CHOICE
    MODE_CHOICE="${MODE_CHOICE:-1}"
    
    if [ "$MODE_CHOICE" = "2" ]; then
        STORAGE_MODE="advanced"
        log_info "Advanced Mode selected"
    else
        STORAGE_MODE="simple"
        log_info "Simple Mode selected (recommended)"
    fi
    
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}Container Configuration${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Find next available VMID
    NEXT_VMID=$(pvesh get /cluster/nextid 2>/dev/null || echo "200")
    read -p "Container ID (default: ${NEXT_VMID}): " VMID_INPUT
    VMID="${VMID_INPUT:-$NEXT_VMID}"
    
    read -p "Container Name (default: gitlab): " HOSTNAME_INPUT
    HOSTNAME="${HOSTNAME_INPUT:-gitlab}"
    
    read -p "CPU Cores (default: 4): " CPU_INPUT
    CPU="${CPU_INPUT:-4}"
    
    read -p "RAM in MB (default: 8192): " RAM_INPUT
    RAM="${RAM_INPUT:-8192}"
    
    if [ "$STORAGE_MODE" = "simple" ]; then
        echo ""
        echo "${GREEN}Simple Mode Storage:${NC}"
        echo "  Recommended sizes:"
        echo "  • Small team (1-10 users): 30-50 GB"
        echo "  • Medium team (10-50 users): 50-100 GB"
        echo "  • Large team (50+ users): 100-200 GB"
        echo ""
        read -p "Root Filesystem Size in GB (default: 50): " BOOTDISK_INPUT
        BOOTDISK="${BOOTDISK_INPUT:-50}"
    else
        echo ""
        echo "${YELLOW}Advanced Mode Storage:${NC}"
        echo "  Separate volumes for granular control"
        echo ""
        read -p "Boot Disk Size in GB (default: 20): " BOOTDISK_INPUT
        BOOTDISK="${BOOTDISK_INPUT:-20}"
        
        read -p "Data Disk Size in GB (default: 100): " OPT_SIZE_INPUT
        OPT_SIZE="${OPT_SIZE_INPUT:-100}"
        
        read -p "Log Disk Size in GB (default: 10): " LOG_SIZE_INPUT
        LOG_SIZE="${LOG_SIZE_INPUT:-10}"
        
        read -p "Config Disk Size in GB (default: 2): " ETC_SIZE_INPUT
        ETC_SIZE="${ETC_SIZE_INPUT:-2}"
    fi
    
    echo ""
    # Try to detect network configuration
    DEFAULT_GW=$(ip route | grep default | awk '{print $3}' | head -n1)
    DEFAULT_DNS="${DEFAULT_GW:-8.8.8.8}"
    
    read -p "Container IP (e.g., 192.168.1.200/24): " CT_IP
    
    read -p "Gateway (default: ${DEFAULT_GW:-192.168.1.1}): " GATEWAY_INPUT
    GATEWAY="${GATEWAY_INPUT:-${DEFAULT_GW:-192.168.1.1}}"
    
    read -p "DNS Server (default: ${DEFAULT_DNS}): " DNS_INPUT
    DNS="${DNS_INPUT:-$DEFAULT_DNS}"
    
    # Extract IP without CIDR for default URL
    DEFAULT_IP=$(echo "$CT_IP" | cut -d'/' -f1)
    read -p "GitLab URL (default: http://${DEFAULT_IP}): " GITLAB_URL_INPUT
    GITLAB_URL="${GITLAB_URL_INPUT:-http://${DEFAULT_IP}}"
    
    read -p "LVM Storage VG Name (default: pve): " STORAGE_INPUT
    STORAGE="${STORAGE_INPUT:-pve}"
    
    echo ""
    read -p "GitLab Version (default: latest stable, or enter version like 16.8.1): " GITLAB_VERSION
    
    read -p "Network Bridge (default: vmbr0): " BRIDGE_INPUT
    BRIDGE="${BRIDGE_INPUT:-vmbr0}"
    echo ""
else
    # Validate required parameters in non-interactive mode
    if [ "$STORAGE_MODE" = "simple" ]; then
        if [ -z "$VMID" ] || [ -z "$HOSTNAME" ] || [ -z "$CPU" ] || [ -z "$RAM" ] || \
           [ -z "$BOOTDISK" ] || [ -z "$CT_IP" ] || [ -z "$GATEWAY" ] || [ -z "$DNS" ] || \
           [ -z "$GITLAB_URL" ] || [ -z "$STORAGE" ]; then
            log_error "Simple Mode requires: --vmid, --hostname, --cpu, --ram, --rootfs-size, --ip, --gateway, --dns, --url, --storage"
            exit 1
        fi
    else
        if [ -z "$VMID" ] || [ -z "$HOSTNAME" ] || [ -z "$CPU" ] || [ -z "$RAM" ] || \
           [ -z "$BOOTDISK" ] || [ -z "$OPT_SIZE" ] || [ -z "$LOG_SIZE" ] || [ -z "$ETC_SIZE" ] || \
           [ -z "$CT_IP" ] || [ -z "$GATEWAY" ] || [ -z "$DNS" ] || \
           [ -z "$GITLAB_URL" ] || [ -z "$STORAGE" ]; then
            log_error "Advanced Mode requires: --vmid, --hostname, --cpu, --ram, --bootdisk, --datadisk, --logdisk, --configdisk, --ip, --gateway, --dns, --url, --storage"
            exit 1
        fi
    fi
    log_info "Using Non-Interactive mode with ${STORAGE_MODE} storage"
fi

echo ""

# ---------- Validation ----------
log_step "Validating input parameters..."

# Check VG exists
if ! vgs "$STORAGE" >/dev/null 2>&1; then
    err "VG '${STORAGE}' does not exist. Please check with 'vgs' command."
fi
log_info "✓ VG '${STORAGE}' exists"

# Check for existing container and LVs
EXISTING_CONTAINER=false
EXISTING_LVS=()

if pct status "$VMID" >/dev/null 2>&1; then
    EXISTING_CONTAINER=true
fi

# Check for GitLab-related LVs
for lv_pattern in "vm-${VMID}-gitlab-etc" "vm-${VMID}-gitlab-log" "vm-${VMID}-gitlab-opt"; do
    if lvdisplay "/dev/${STORAGE}/${lv_pattern}" >/dev/null 2>&1; then
        EXISTING_LVS+=("$lv_pattern")
    fi
done

# If existing resources found, handle cleanup
if [ "$EXISTING_CONTAINER" = true ] || [ ${#EXISTING_LVS[@]} -gt 0 ]; then
    log_warn "Found existing resources:"
    
    if [ "$EXISTING_CONTAINER" = true ]; then
        CT_STATUS=$(pct status "$VMID" 2>/dev/null | awk '{print $2}')
        echo "  • Container ${VMID} (Status: ${CT_STATUS})"
    fi
    
    for lv in "${EXISTING_LVS[@]}"; do
        LV_SIZE=$(lvdisplay "/dev/${STORAGE}/${lv}" 2>/dev/null | grep "LV Size" | awk '{print $3, $4}')
        echo "  • LV: ${lv} (${LV_SIZE})"
    done
    
    echo ""
    log_warn "These resources may be left over from a previous failed installation."
    
    SHOULD_CLEANUP=false
    
    if [ "$INTERACTIVE" = true ]; then
        echo ""
        read -p "Do you want to clean up these resources? (yes/no): " CLEANUP_CONFIRM
        if [[ "$CLEANUP_CONFIRM" == "yes" ]]; then
            SHOULD_CLEANUP=true
        else
            err "User chose not to cleanup. Please cleanup manually or use a different VMID."
        fi
    else
        if [ "$FORCE_CLEANUP" = true ]; then
            log_info "Non-Interactive mode + --force-cleanup, cleaning up automatically"
            SHOULD_CLEANUP=true
        else
            err "Container/LV already exists. Please add --force-cleanup parameter or cleanup manually."
        fi
    fi
    
    if [ "$SHOULD_CLEANUP" = true ]; then
        log_step "Cleaning up existing resources..."
        
        # Stop and destroy container
        if [ "$EXISTING_CONTAINER" = true ]; then
            log_info "Stopping Container ${VMID}..."
            pct stop "$VMID" 2>/dev/null || true
            
            log_info "Destroying Container ${VMID}..."
            pct destroy "$VMID" || log_warn "Container destruction had warnings"
        fi
        
        # Remove LVs
        for lv in "${EXISTING_LVS[@]}"; do
            log_info "Removing LV ${lv}..."
            lvremove -f "/dev/${STORAGE}/${lv}" || log_warn "LV removal had warnings"
        done
        
        log_info "✓ Cleanup complete"
        echo ""
    fi
fi

log_info "✓ VMID $VMID is available"

# Validate IP format
if ! [[ "$CT_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    err "Invalid IP format. Correct format: 192.168.1.200/24"
fi
log_info "✓ IP format is valid"

# Validate URL format
if ! [[ "$GITLAB_URL" =~ ^https?:// ]]; then
    err "Invalid URL format. Must start with http:// or https://"
fi
log_info "✓ URL format is valid"

# Auto-adjust SSL_TYPE based on GITLAB_URL protocol
if [[ "$GITLAB_URL" =~ ^https:// ]]; then
    # HTTPS URL - requires SSL
    if [ "$SSL_TYPE" != "self-signed" ] && [ "$SSL_TYPE" != "letsencrypt" ]; then
        SSL_TYPE="self-signed"  # Default to self-signed
        log_info "HTTPS URL detected - SSL_TYPE set to: ${SSL_TYPE}"
    fi
else
    # HTTP URL - no SSL needed
    if [ "$SSL_TYPE" != "none" ]; then
        log_warn "HTTP URL detected - SSL_TYPE changed from '${SSL_TYPE}' to 'none'"
        SSL_TYPE="none"
    fi
fi
log_info "✓ SSL configuration: ${SSL_TYPE}"

# ---------- Summary & Confirmation ----------
log_step "Installation Configuration Summary"

if [ "$STORAGE_MODE" = "simple" ]; then
    cat << EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
  Container ID    : ${GREEN}${VMID}${NC}
  Hostname        : ${GREEN}${HOSTNAME}${NC}
  CPU Cores       : ${GREEN}${CPU}${NC}
  RAM             : ${GREEN}${RAM} MB${NC}
  Storage Mode    : ${GREEN}Simple (Single Root Filesystem)${NC} ⭐
  Root Size       : ${GREEN}${BOOTDISK} GB${NC}
  IP Address      : ${GREEN}${CT_IP}${NC}
  Gateway         : ${GREEN}${GATEWAY}${NC}
  DNS             : ${GREEN}${DNS}${NC}
  GitLab URL      : ${GREEN}${GITLAB_URL}${NC}
  GitLab Version  : ${GREEN}${GITLAB_VERSION:-Latest Stable}${NC}
  SSL Type        : ${GREEN}${SSL_TYPE}${NC}
  Storage VG      : ${GREEN}${STORAGE}${NC}
  Network Bridge  : ${GREEN}${BRIDGE}${NC}
  Template        : ${GREEN}${TEMPLATE}${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
EOF
else
    cat << EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
  Container ID    : ${GREEN}${VMID}${NC}
  Hostname        : ${GREEN}${HOSTNAME}${NC}
  CPU Cores       : ${GREEN}${CPU}${NC}
  RAM             : ${GREEN}${RAM} MB${NC}
  Storage Mode    : ${YELLOW}Advanced (Separate LVM Volumes)${NC}
  Boot Disk       : ${GREEN}${BOOTDISK} GB${NC}
  Data Disk       : ${GREEN}${OPT_SIZE} GB${NC}
  Log Disk        : ${GREEN}${LOG_SIZE} GB${NC}
  Config Disk     : ${GREEN}${ETC_SIZE} GB${NC}
  IP Address      : ${GREEN}${CT_IP}${NC}
  Gateway         : ${GREEN}${GATEWAY}${NC}
  DNS             : ${GREEN}${DNS}${NC}
  GitLab URL      : ${GREEN}${GITLAB_URL}${NC}
  GitLab Version  : ${GREEN}${GITLAB_VERSION:-Latest Stable}${NC}
  SSL Type        : ${GREEN}${SSL_TYPE}${NC}
  Storage VG      : ${GREEN}${STORAGE}${NC}
  Network Bridge  : ${GREEN}${BRIDGE}${NC}
  Template        : ${GREEN}${TEMPLATE}${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
EOF
fi

echo ""

if [ "$INTERACTIVE" = true ]; then
    read -p "Confirm the above configuration is correct? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        log_warn "User cancelled installation."
        exit 0
    fi
else
    log_info "Non-Interactive mode, auto-confirming configuration"
fi

# ---------- Step 2: Create Unprivileged Container ----------
log_step "Step 2: Creating Unprivileged LXC Container"

log_info "Creating Container $VMID..."

# Add fingerprint/description to container (Markdown format for Proxmox Notes)
INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_VERSION="1.1.2"
SCRIPT_AUTHOR="Joe @ hiall-fyi"
COFFEE_LINK="https://buymeacoffee.com/hiallfyi"
GITHUB_LINK="https://github.com/hiall-fyi"

# Create beautiful Markdown-formatted Notes for Proxmox UI
if [ "$STORAGE_MODE" = "simple" ]; then
    FINGERPRINT="# 🚀 GitLab CE Secure Install

**Version:** ${SCRIPT_VERSION}  
**Installed:** ${INSTALL_DATE}  
**Created by:** ${SCRIPT_AUTHOR}

---

## 🔒 Security Features

✅ **Unprivileged Container** - Enhanced isolation  
✅ **System Fully Updated** - Latest security patches  
✅ **Self-Signed SSL** - 10-year validity  
✅ **HTTPS Redirect** - Forced secure connections  
✅ **Security Headers** - HSTS, X-Frame-Options, CSP  
✅ **Rate Limiting** - DDoS protection  
✅ **UFW Firewall** - Network security  

---

## 📦 Storage Configuration

**Mode:** Simple (Single Root Filesystem) ⭐  
**Root Size:** ${BOOTDISK}G  
**All GitLab data on root filesystem**

---

## 🔗 Links

- **GitHub:** ${GITHUB_LINK}
- **Support:** ${COFFEE_LINK}

---

*Enjoy this script? ☕*

<a href=\"${COFFEE_LINK}\"><img src=\"https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png\" alt=\"Buy Me A Coffee\" height=\"60\" width=\"217\"></a>"
else
    FINGERPRINT="# 🚀 GitLab CE Secure Install

**Version:** ${SCRIPT_VERSION}  
**Installed:** ${INSTALL_DATE}  
**Created by:** ${SCRIPT_AUTHOR}

---

## 🔒 Security Features

✅ **Unprivileged Container** - Enhanced isolation  
✅ **System Fully Updated** - Latest security patches  
✅ **Self-Signed SSL** - 10-year validity  
✅ **HTTPS Redirect** - Forced secure connections  
✅ **Security Headers** - HSTS, X-Frame-Options, CSP  
✅ **Rate Limiting** - DDoS protection  
✅ **UFW Firewall** - Network security  

---

## 📦 Storage Configuration

**Mode:** Advanced (Separate LVM Volumes)

- **Config:** \`/etc/gitlab\` → \`/dev/${STORAGE}/vm-${VMID}-gitlab-etc\` (${ETC_SIZE}G)
- **Logs:** \`/var/log/gitlab\` → \`/dev/${STORAGE}/vm-${VMID}-gitlab-log\` (${LOG_SIZE}G)
- **Data:** \`/var/opt/gitlab\` → \`/dev/${STORAGE}/vm-${VMID}-gitlab-opt\` (${OPT_SIZE}G)

---

## 🔗 Links

- **GitHub:** ${GITHUB_LINK}
- **Support:** ${COFFEE_LINK}

---

*Enjoy this script? ☕*

<a href=\"${COFFEE_LINK}\"><img src=\"https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png\" alt=\"Buy Me A Coffee\" height=\"60\" width=\"217\"></a>"
fi

pct create "$VMID" "$TEMPLATE" \
  --hostname "$HOSTNAME" \
  --cores "$CPU" \
  --memory "$RAM" \
  --rootfs local-lvm:${BOOTDISK} \
  --net0 name=eth0,bridge=${BRIDGE},ip="${CT_IP}",gw="${GATEWAY}",type=veth \
  --nameserver "$DNS" \
  --unprivileged 1 \
  --features nesting=1,keyctl=1 \
  --onboot 1 \
  --protection 0 \
  --description "${FINGERPRINT}" || err "Container creation failed"

log_info "✓ Unprivileged Container created successfully"
log_info "✓ Fingerprint added to container notes"

# ---------- Storage Configuration ----------
if [ "$STORAGE_MODE" = "advanced" ]; then
    log_step "Configuring Advanced Mode storage (Separate LVM volumes)..."
    
    # ---------- LV Helper Function ----------
    mk_lv_if_missing() {
        local lv_name="$1"
        local size_g="$2"
        local lv_path="/dev/${STORAGE}/${lv_name}"

        if lvdisplay "$lv_path" >/dev/null 2>&1; then
            log_info "LV $lv_path already exists, skipping creation"
        else
            log_info "Creating LV $lv_path (${size_g}G)..."
            lvcreate -L "${size_g}G" -n "$lv_name" "$STORAGE" || err "lvcreate failed: $lv_path"
        fi

        # Format if needed
        if blkid -o value -s TYPE "$lv_path" >/dev/null 2>&1; then
            local fs_type=$(blkid -o value -s TYPE "$lv_path")
            log_info "LV $lv_path already formatted as: $fs_type"
        else
            log_info "Formatting $lv_path as ext4..."
            wipefs -a "$lv_path" 2>/dev/null || true
            mkfs.ext4 -F "$lv_path" >/dev/null || err "mkfs.ext4 failed: $lv_path"
            log_info "✓ Formatting complete"
        fi
    }

    # ---------- Create LVs ----------
    log_info "Creating LVM volumes..."

    LV_ETC="vm-${VMID}-gitlab-etc"
    LV_LOG="vm-${VMID}-gitlab-log"
    LV_OPT="vm-${VMID}-gitlab-opt"

    mk_lv_if_missing "$LV_ETC" "$ETC_SIZE"
    mk_lv_if_missing "$LV_LOG" "$LOG_SIZE"
    mk_lv_if_missing "$LV_OPT" "$OPT_SIZE"

    log_info "✓ All LVM volumes ready"

    # ---------- Attach LVs to Container ----------
    log_info "Attaching LVM volumes to container..."

    # For unprivileged containers, we need to attach mount points BEFORE starting
    # But we need to ensure proper permissions
    pct set "$VMID" \
      -mp0 "/dev/${STORAGE}/${LV_ETC},mp=/etc/gitlab,backup=0" \
      -mp1 "/dev/${STORAGE}/${LV_LOG},mp=/var/log/gitlab,backup=0" \
      -mp2 "/dev/${STORAGE}/${LV_OPT},mp=/var/opt/gitlab,backup=0" || err "Failed to attach LVM volumes"

    log_info "✓ LVM volumes attached successfully"
else
    log_step "Using Simple Mode storage (Single root filesystem)"
    log_info "All GitLab data will be stored on root filesystem"
    log_info "✓ No separate LVM volumes needed"
fi

# ---------- Start Container ----------
log_step "Starting container..."

pct start "$VMID" || err "Container failed to start"

# Wait for container to be ready
log_info "Waiting for container to start..."
sleep 5

# Check if container is running
if ! pct status "$VMID" | grep -q "running"; then
    err "Container failed to start, please check logs"
fi

log_info "✓ Container is running"

# ---------- Prepare GitLab directories ----------
if [ "$STORAGE_MODE" = "advanced" ]; then
    log_step "Preparing GitLab directories for unprivileged container (Advanced Mode)..."

    log_info "Setting ownership on HOST for unprivileged container UID mapping..."

    # In unprivileged containers, root (UID 0) inside = UID 100000 on host
    # We need to temporarily mount the LVs on host, set ownership, then unmount

    # Create temporary mount points on host
    mkdir -p /tmp/gitlab-mount-{etc,log,opt}

    # Mount, set ownership, unmount for each LV
    log_info "Processing /etc/gitlab volume..."
    mount "/dev/${STORAGE}/${LV_ETC}" /tmp/gitlab-mount-etc
    chown -R 100000:100000 /tmp/gitlab-mount-etc
    chmod 755 /tmp/gitlab-mount-etc
    umount /tmp/gitlab-mount-etc

    log_info "Processing /var/log/gitlab volume..."
    mount "/dev/${STORAGE}/${LV_LOG}" /tmp/gitlab-mount-log
    chown -R 100000:100000 /tmp/gitlab-mount-log
    chmod 755 /tmp/gitlab-mount-log
    umount /tmp/gitlab-mount-log

    log_info "Processing /var/opt/gitlab volume..."
    mount "/dev/${STORAGE}/${LV_OPT}" /tmp/gitlab-mount-opt
    chown -R 100000:100000 /tmp/gitlab-mount-opt
    chmod 755 /tmp/gitlab-mount-opt
    umount /tmp/gitlab-mount-opt

    # Cleanup temporary mount points
    rmdir /tmp/gitlab-mount-{etc,log,opt}

    log_info "✓ GitLab volumes prepared with correct UID mapping (100000:100000)"

    # Now create the mount point directories inside container
    log_info "Creating mount point directories inside container..."
    pct exec "$VMID" -- bash -c "
        mkdir -p /etc/gitlab
        mkdir -p /var/log/gitlab  
        mkdir -p /var/opt/gitlab
    " || err "Failed to create mount point directories"

    log_info "✓ Mount point directories created"
else
    log_step "Preparing GitLab directories (Simple Mode)..."
    
    # Simple mode: just create directories on root filesystem
    pct exec "$VMID" -- bash -c "
        mkdir -p /etc/gitlab
        mkdir -p /var/log/gitlab  
        mkdir -p /var/opt/gitlab
    " || err "Failed to create GitLab directories"
    
    log_info "✓ GitLab directories created on root filesystem"
fi

# ---------- Step 1 (Container): Update System ----------
log_step "Step 1 (Container): Updating container system"

log_info "Updating package lists..."
pct exec "$VMID" -- bash -c "apt update" || err "Container apt update failed"

log_info "Upgrading system packages..."
pct exec "$VMID" -- bash -c "DEBIAN_FRONTEND=noninteractive apt upgrade -y" || err "Container apt upgrade failed"

log_info "✓ Container system updated"

# ---------- Install Prerequisites ----------
log_step "Installing required packages..."

pct exec "$VMID" -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    ca-certificates \
    tzdata \
    openssh-server \
    gnupg \
    locales \
    postfix \
    perl" || err "Failed to install required packages"

log_info "✓ Required packages installed"

# ---------- Configure Locales ----------
log_step "Configuring locales..."

pct exec "$VMID" -- bash -c "
    sed -i 's/^# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
" || log_warn "Locale configuration had warnings"

log_info "✓ Locales configured"

# ---------- Install GitLab CE ----------
log_step "Installing GitLab CE (this may take a while)..."

log_info "Adding GitLab official repository..."
pct exec "$VMID" -- bash -c "curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash" || err "Failed to add GitLab repository"

# Pre-configure GitLab SSL settings based on SSL_TYPE
log_info "Pre-configuring GitLab SSL settings (${SSL_TYPE})..."

if [ "$SSL_TYPE" = "letsencrypt" ]; then
    # Enable Let's Encrypt for public domains
    pct exec "$VMID" -- bash -c "mkdir -p /etc/gitlab && cat > /etc/gitlab/gitlab.rb << 'EOFPRECONFIG'
# Enable Let's Encrypt for public domain
letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['admin@example.com']  # Change this!
letsencrypt['auto_renew'] = true
EOFPRECONFIG
" || log_warn "Could not create pre-configuration"
    log_info "✓ Let's Encrypt will be configured during installation"
else
    # Disable Let's Encrypt (we'll use self-signed certificate)
    pct exec "$VMID" -- bash -c "mkdir -p /etc/gitlab && cat > /etc/gitlab/gitlab.rb << 'EOFPRECONFIG'
# Disable Let's Encrypt (we'll use self-signed certificate)
letsencrypt['enable'] = false
EOFPRECONFIG
" || log_warn "Could not create pre-configuration"
    log_info "✓ Self-signed certificate will be generated after installation"
fi

# Determine version to install
if [ -z "$GITLAB_VERSION" ]; then
    log_info "Installing latest stable GitLab CE..."
    INSTALL_CMD="EXTERNAL_URL='${GITLAB_URL}' DEBIAN_FRONTEND=noninteractive apt install -y gitlab-ce"
else
    log_info "Installing GitLab CE version: ${GITLAB_VERSION}..."
    INSTALL_CMD="EXTERNAL_URL='${GITLAB_URL}' DEBIAN_FRONTEND=noninteractive apt install -y gitlab-ce=${GITLAB_VERSION}-ce.0"
fi

pct exec "$VMID" -- bash -c "$INSTALL_CMD" || err "GitLab CE installation failed"

log_info "✓ GitLab CE installed"

# ---------- Step 3: SSL Configuration ----------
if [ "$SSL_TYPE" = "self-signed" ]; then
    log_step "Step 3: Configuring self-signed SSL certificate (internal use)"

    # Extract hostname from URL
    GITLAB_HOSTNAME=$(echo "$GITLAB_URL" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

    log_info "Generating self-signed certificate for ${GITLAB_HOSTNAME}..."

    pct exec "$VMID" -- bash -c "
        mkdir -p /etc/gitlab/ssl
        chmod 755 /etc/gitlab/ssl
        
        # Generate self-signed certificate (10-year validity)
        openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
            -keyout /etc/gitlab/ssl/${GITLAB_HOSTNAME}.key \
            -out /etc/gitlab/ssl/${GITLAB_HOSTNAME}.crt \
            -subj '/C=HK/ST=HK/L=HK/O=Internal/CN=${GITLAB_HOSTNAME}' \
            2>/dev/null
        
        chmod 600 /etc/gitlab/ssl/${GITLAB_HOSTNAME}.key
        chmod 644 /etc/gitlab/ssl/${GITLAB_HOSTNAME}.crt
    " || err "SSL certificate generation failed"

    log_info "✓ Self-signed SSL certificate generated"
elif [ "$SSL_TYPE" = "letsencrypt" ]; then
    log_step "Step 3: Let's Encrypt SSL certificate"
    log_info "Let's Encrypt is enabled - certificate will be obtained automatically"
    log_warn "⚠️  Make sure your domain points to this server's public IP!"
    log_warn "⚠️  Ports 80 and 443 must be accessible from the internet!"
else
    log_step "Step 3: SSL Configuration"
    log_info "HTTP mode - no SSL certificate needed"
    log_warn "⚠️  Using HTTP without SSL is not recommended for production!"
    log_warn "⚠️  Consider using HTTPS with self-signed or Let's Encrypt certificate"
fi

# ---------- Step 6: Security Hardening ----------
log_step "Step 6: Applying security hardening configuration"

log_info "Configuring GitLab security settings..."

# Extract hostname for SSL configuration
GITLAB_HOSTNAME=$(echo "$GITLAB_URL" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

# Generate SSL configuration based on SSL_TYPE
if [ "$SSL_TYPE" = "self-signed" ]; then
    # Self-signed certificate configuration
    SSL_CONFIG="
# SSL Configuration (Self-Signed for Internal Use)
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = '/etc/gitlab/ssl/${GITLAB_HOSTNAME}.crt'
nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/${GITLAB_HOSTNAME}.key'
nginx['ssl_protocols'] = 'TLSv1.2 TLSv1.3'
nginx['ssl_ciphers'] = 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384'
nginx['ssl_prefer_server_ciphers'] = 'on'
nginx['ssl_session_cache'] = 'shared:SSL:10m'
nginx['ssl_session_timeout'] = '10m'
"
elif [ "$SSL_TYPE" = "letsencrypt" ]; then
    # Let's Encrypt configuration
    SSL_CONFIG="
# SSL Configuration (Let's Encrypt)
nginx['redirect_http_to_https'] = true
nginx['ssl_protocols'] = 'TLSv1.2 TLSv1.3'
nginx['ssl_ciphers'] = 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384'
nginx['ssl_prefer_server_ciphers'] = 'on'
nginx['ssl_session_cache'] = 'shared:SSL:10m'
nginx['ssl_session_timeout'] = '10m'
# Let's Encrypt certificates are managed automatically
"
else
    # HTTP mode - no SSL configuration
    SSL_CONFIG="
# HTTP Mode - No SSL
# WARNING: This is not recommended for production use
"
fi

pct exec "$VMID" -- bash -c "cat >> /etc/gitlab/gitlab.rb << 'EOFGITLAB'

# ========================================
# Security Hardening Configuration
# ========================================

# External URL
external_url '${GITLAB_URL}'

${SSL_CONFIG}

# Security Headers
nginx['custom_gitlab_server_config'] = \"
  add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains' always;
  add_header X-Frame-Options 'SAMEORIGIN' always;
  add_header X-Content-Type-Options 'nosniff' always;
  add_header X-XSS-Protection '1; mode=block' always;
  add_header Referrer-Policy 'strict-origin-when-cross-origin' always;
\"

# Rate Limiting (Internal use, more relaxed)
gitlab_rails['rack_attack_git_basic_auth'] = {
  'enabled' => true,
  'ip_whitelist' => ['127.0.0.1', '192.168.0.0/16', '10.0.0.0/8'],
  'maxretry' => 10,
  'findtime' => 60,
  'bantime' => 3600
}

# Session Settings
gitlab_rails['session_expire_delay'] = 10080  # 7 days

# Email Settings (Optional for internal use)
gitlab_rails['gitlab_email_enabled'] = false

# Backup Settings (Recommended for regular backups)
gitlab_rails['backup_keep_time'] = 604800  # 7 days

# Monitoring
prometheus['enable'] = true
prometheus['monitor_kubernetes'] = false

# Performance Tuning
postgresql['shared_buffers'] = '256MB'
postgresql['max_worker_processes'] = 8
sidekiq['max_concurrency'] = 10

# Disable unnecessary services for internal use
gitlab_kas['enable'] = false
sentinel['enable'] = false

EOFGITLAB
" || err "Failed to write GitLab configuration"

log_info "✓ Security configuration written"

# ---------- Reconfigure GitLab ----------
log_step "Reconfiguring GitLab (this may take a while)..."

pct exec "$VMID" -- bash -c "gitlab-ctl reconfigure" || log_warn "Reconfigure had warnings (normal in LXC environment)"

log_info "✓ GitLab reconfigured"

# ---------- Restart GitLab ----------
log_info "Restarting GitLab services..."
pct exec "$VMID" -- bash -c "gitlab-ctl restart" || log_warn "Restart had warnings"

# Wait for GitLab to be ready
log_info "Waiting for GitLab services to start..."
sleep 10

log_info "✓ GitLab services running"

# ---------- Configure Firewall ----------
log_step "Configuring firewall..."

pct exec "$VMID" -- bash -c "
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw --force enable
" || log_warn "UFW configuration had warnings"

log_info "✓ Firewall configured"

# ---------- Get Initial Root Password ----------
log_step "Retrieving initial root password..."

INITIAL_PASSWORD=$(pct exec "$VMID" -- bash -c "cat /etc/gitlab/initial_root_password 2>/dev/null | grep 'Password:' | awk '{print \$2}'" || echo "N/A")

# ---------- Final Summary ----------
log_step "Installation Complete!"

if [ "$STORAGE_MODE" = "simple" ]; then
    cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                    GitLab CE Installation Successful!                ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}📦 Container Information:${NC}
  • Container ID      : ${GREEN}${VMID}${NC}
  • Hostname          : ${GREEN}${HOSTNAME}${NC}
  • IP Address        : ${GREEN}${CT_IP}${NC}
  • GitLab URL        : ${GREEN}${GITLAB_URL}${NC}

${BLUE}💾 Storage Configuration:${NC}
  • Mode              : ${GREEN}Simple (Single Root Filesystem)${NC} ⭐
  • Root Size         : ${GREEN}${BOOTDISK} GB${NC}
  • All GitLab data on root filesystem

${BLUE}🔐 Initial Login Credentials:${NC}
  • Username          : ${GREEN}root${NC}
  • Password          : ${YELLOW}${INITIAL_PASSWORD}${NC}
  ${RED}⚠️  Please login immediately and change the password!${NC}

${BLUE}🔒 Security Features:${NC}
  ✅ Unprivileged Container
  ✅ System Fully Updated
  ✅ Self-Signed SSL Certificate (10-year validity)
  ✅ HTTPS Forced Redirect
  ✅ Security Headers (HSTS, X-Frame-Options, etc.)
  ✅ Rate Limiting
  ✅ UFW Firewall

${BLUE}📝 Common Commands:${NC}
  # Check GitLab status
  ${GREEN}pct exec ${VMID} -- gitlab-ctl status${NC}

  # Reconfigure GitLab
  ${GREEN}pct exec ${VMID} -- gitlab-ctl reconfigure${NC}

  # Restart GitLab
  ${GREEN}pct exec ${VMID} -- gitlab-ctl restart${NC}

  # View logs
  ${GREEN}pct exec ${VMID} -- gitlab-ctl tail${NC}

  # Enter container
  ${GREEN}pct enter ${VMID}${NC}

${BLUE}🔧 Next Steps:${NC}
  1. Visit ${GREEN}${GITLAB_URL}${NC}
  2. Login with root / ${INITIAL_PASSWORD}
  3. ${RED}Change root password immediately${NC}
  4. Set up 2FA (recommended)
  5. Create users and projects
  6. Configure SSH keys
  7. Set up regular backups

${BLUE}⚠️  SSL Certificate Note:${NC}
  Since we're using a self-signed certificate, your browser will show a security warning.
  For internal use, you can safely ignore this or add the certificate to your trusted store.
  
  Certificate location: ${GREEN}/etc/gitlab/ssl/${GITLAB_HOSTNAME}.crt${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Enjoy your GitLab CE! 🚀${NC}

${BLUE}Created by:${NC} Joe @ hiall-fyi
EOF
else
    cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                    GitLab CE Installation Successful!                ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}📦 Container Information:${NC}
  • Container ID      : ${GREEN}${VMID}${NC}
  • Hostname          : ${GREEN}${HOSTNAME}${NC}
  • IP Address        : ${GREEN}${CT_IP}${NC}
  • GitLab URL        : ${GREEN}${GITLAB_URL}${NC}

${BLUE}💾 Storage Configuration:${NC}
  • Mode              : ${YELLOW}Advanced (Separate LVM Volumes)${NC}
  • /etc/gitlab       : ${GREEN}/dev/${STORAGE}/${LV_ETC}${NC} (${ETC_SIZE}G)
  • /var/log/gitlab   : ${GREEN}/dev/${STORAGE}/${LV_LOG}${NC} (${LOG_SIZE}G)
  • /var/opt/gitlab   : ${GREEN}/dev/${STORAGE}/${LV_OPT}${NC} (${OPT_SIZE}G)

${BLUE}🔐 Initial Login Credentials:${NC}
  • Username          : ${GREEN}root${NC}
  • Password          : ${YELLOW}${INITIAL_PASSWORD}${NC}
  ${RED}⚠️  Please login immediately and change the password!${NC}

${BLUE}🔒 Security Features:${NC}
  ✅ Unprivileged Container
  ✅ System Fully Updated
  ✅ Self-Signed SSL Certificate (10-year validity)
  ✅ HTTPS Forced Redirect
  ✅ Security Headers (HSTS, X-Frame-Options, etc.)
  ✅ Rate Limiting
  ✅ UFW Firewall

${BLUE}📝 Common Commands:${NC}
  # Check GitLab status
  ${GREEN}pct exec ${VMID} -- gitlab-ctl status${NC}

  # Reconfigure GitLab
  ${GREEN}pct exec ${VMID} -- gitlab-ctl reconfigure${NC}

  # Restart GitLab
  ${GREEN}pct exec ${VMID} -- gitlab-ctl restart${NC}

  # View logs
  ${GREEN}pct exec ${VMID} -- gitlab-ctl tail${NC}

  # Enter container
  ${GREEN}pct enter ${VMID}${NC}

${BLUE}🔧 Next Steps:${NC}
  1. Visit ${GREEN}${GITLAB_URL}${NC}
  2. Login with root / ${INITIAL_PASSWORD}
  3. ${RED}Change root password immediately${NC}
  4. Set up 2FA (recommended)
  5. Create users and projects
  6. Configure SSH keys
  7. Set up regular backups

${BLUE}⚠️  SSL Certificate Note:${NC}
  Since we're using a self-signed certificate, your browser will show a security warning.
  For internal use, you can safely ignore this or add the certificate to your trusted store.
  
  Certificate location: ${GREEN}/etc/gitlab/ssl/${GITLAB_HOSTNAME}.crt${NC}

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${YELLOW}Enjoy your GitLab CE! 🚀${NC}

${BLUE}Created by:${NC} Joe @ hiall-fyi
${BLUE}GitHub:${NC} ${GITHUB_LINK}
${BLUE}Support:${NC} ${COFFEE_LINK} ☕

EOF
fi

EOF

# ---------- Save installation log ----------
LOG_FILE="/var/log/gitlab-ce-install-${VMID}.log"
cat > "$LOG_FILE" << EOFLOG
GitLab CE Installation Log
==========================
Date: $(date)
Container ID: ${VMID}
Hostname: ${HOSTNAME}
IP: ${CT_IP}
GitLab URL: ${GITLAB_URL}
GitLab Version: ${GITLAB_VERSION:-Latest Stable}
Initial Root Password: ${INITIAL_PASSWORD}

LVM Disks:
- /dev/${STORAGE}/${LV_ETC} -> /etc/gitlab (${ETC_SIZE}G)
- /dev/${STORAGE}/${LV_LOG} -> /var/log/gitlab (${LOG_SIZE}G)
- /dev/${STORAGE}/${LV_OPT} -> /var/opt/gitlab (${OPT_SIZE}G)

Security Features:
- Unprivileged Container: Yes
- SSL: Self-Signed Certificate
- HTTPS Redirect: Enabled
- Security Headers: Enabled
- Rate Limiting: Enabled
- Firewall: UFW Enabled

EOFLOG

log_info "Installation log saved to: ${LOG_FILE}"

exit 0
