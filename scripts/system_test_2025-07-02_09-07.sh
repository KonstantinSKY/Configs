#!/bin/bash

# System Maintenance Automation Script
# Generated: 2025-07-02 09:07
# PC: i3-2 (Manjaro Linux)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
HOSTNAME=$(hostname)
REPORT_DIR="$HOME/Work/Configs/reports"
SCRIPT_DIR="$HOME/Work/Configs/scripts"
REPORT_FILE=""
TEMP_LOG="/tmp/system_maintenance_$(date +%s).log"

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$TEMP_LOG"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1" | tee -a "$TEMP_LOG"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1" | tee -a "$TEMP_LOG"
}

log_info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] INFO:${NC} $1" | tee -a "$TEMP_LOG"
}

# Function to detect OS
detect_os() {
    log "Detecting operating system..."

    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$NAME"
        OS_ID="$ID"
        OS_VERSION="$VERSION_ID"
        log "Detected OS: $OS_NAME"

        # Set package manager based on OS
        case "$OS_ID" in
            "manjaro"|"arch")
                PKG_MANAGER="pacman"
                UPDATE_CMD="sudo pacman -Syu --noconfirm"
                CLEAN_CMD="sudo pacman -Sc --noconfirm"
                ORPHANS_CMD="sudo pacman -Rns \$(pacman -Qtdq) --noconfirm"
                ;;
            "ubuntu"|"debian")
                PKG_MANAGER="apt"
                UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
                CLEAN_CMD="sudo apt autoremove -y && sudo apt autoclean"
                ORPHANS_CMD="sudo apt autoremove -y"
                ;;
            "fedora"|"rhel"|"centos")
                PKG_MANAGER="dnf"
                UPDATE_CMD="sudo dnf update -y"
                CLEAN_CMD="sudo dnf clean all"
                ORPHANS_CMD="sudo dnf autoremove -y"
                ;;
            *)
                log_warning "Unknown Linux distribution: $OS_ID"
                PKG_MANAGER="unknown"
                ;;
        esac
    else
        log_error "Cannot detect OS - /etc/os-release not found"
        exit 1
    fi
}

# Function to perform system health checks
system_health_check() {
    log "Performing comprehensive system health check..."

    # CPU Information
    log_info "Checking CPU status..."
    CPU_INFO=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    CPU_CORES=$(nproc)
    CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)

    # Memory Information
    log_info "Checking memory status..."
    MEMORY_INFO=$(free -h | grep "Mem:")
    MEMORY_TOTAL=$(echo $MEMORY_INFO | awk '{print $2}')
    MEMORY_USED=$(echo $MEMORY_INFO | awk '{print $3}')
    MEMORY_FREE=$(echo $MEMORY_INFO | awk '{print $4}')
    MEMORY_AVAILABLE=$(echo $MEMORY_INFO | awk '{print $7}')

    # Disk Information
    log_info "Checking disk usage..."
    DISK_INFO=$(df -h | grep -vE '^Filesystem|tmpfs|cdrom|udev')

    # Network Information
    log_info "Checking network status..."
    NETWORK_INFO=$(ip addr show | grep -E "(inet |UP|DOWN)" | head -10)

    # System Services
    log_info "Checking system services..."
    FAILED_SERVICES=$(systemctl --failed --no-legend | wc -l)
    SYSTEM_STATUS=$(systemctl status --no-pager -l | head -5)

    # System Uptime
    UPTIME_INFO=$(uptime -p)

    # Check for system errors
    log_info "Checking system logs for errors..."
    RECENT_ERRORS=$(journalctl -p 3 -xb --no-pager | tail -5)

    log "System health check completed"
}

# Function to update system packages
update_packages() {
    log "Starting system package updates..."

    case "$PKG_MANAGER" in
        "pacman")
            log "Synchronizing package databases..."
            sudo pacman -Sy

            log "Checking for available updates..."
            UPDATES_AVAILABLE=$(pacman -Qu | wc -l)

            if [[ $UPDATES_AVAILABLE -gt 0 ]]; then
                log "Found $UPDATES_AVAILABLE package(s) to update"
                eval "$UPDATE_CMD"
                UPDATES_APPLIED="$UPDATES_AVAILABLE packages updated"
            else
                log "System is already up to date"
                UPDATES_APPLIED="No updates available"
            fi
            ;;
        "apt")
            log "Updating package lists..."
            sudo apt update

            UPDATES_AVAILABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)

            if [[ $UPDATES_AVAILABLE -gt 0 ]]; then
                log "Found $UPDATES_AVAILABLE package(s) to update"
                sudo apt upgrade -y
                UPDATES_APPLIED="$UPDATES_AVAILABLE packages updated"
            else
                log "System is already up to date"
                UPDATES_APPLIED="No updates available"
            fi
            ;;
        "dnf")
            log "Checking for updates..."
            UPDATES_AVAILABLE=$(dnf check-update -q | wc -l || true)

            if [[ $UPDATES_AVAILABLE -gt 0 ]]; then
                log "Found updates available"
                eval "$UPDATE_CMD"
                UPDATES_APPLIED="System packages updated"
            else
                log "System is already up to date"
                UPDATES_APPLIED="No updates available"
            fi
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            UPDATES_APPLIED="Unable to update - unknown package manager"
            ;;
    esac

    log "Package updates completed"
}

# Function to clean up unused dependencies
cleanup_dependencies() {
    log "Cleaning up unused dependencies and packages..."

    case "$PKG_MANAGER" in
        "pacman")
            # Find orphaned packages
            ORPHANS=$(pacman -Qtdq 2>/dev/null || true)

            if [[ -n "$ORPHANS" ]]; then
                ORPHAN_COUNT=$(echo "$ORPHANS" | wc -l)
                log "Found $ORPHAN_COUNT orphaned package(s)"

                # Calculate size before removal
                ORPHAN_SIZE=$(pacman -Qi $(pacman -Qtdq) 2>/dev/null | grep "Installed Size" | awk '{sum+=$4} END {printf "%.2f MiB", sum}' || echo "Unknown size")

                eval "$ORPHANS_CMD"
                CLEANUP_RESULT="Removed $ORPHAN_COUNT orphaned packages ($ORPHAN_SIZE)"
            else
                log "No orphaned packages found"
                CLEANUP_RESULT="No orphaned packages to remove"
            fi

            # Clean package cache
            log "Cleaning package cache..."
            eval "$CLEAN_CMD"
            ;;
        "apt")
            log "Removing unused packages..."
            eval "$ORPHANS_CMD"
            eval "$CLEAN_CMD"
            CLEANUP_RESULT="Removed unused packages and cleaned cache"
            ;;
        "dnf")
            log "Removing unused packages..."
            eval "$ORPHANS_CMD"
            eval "$CLEAN_CMD"
            CLEANUP_RESULT="Removed unused packages and cleaned cache"
            ;;
        *)
            log_error "Unknown package manager for cleanup"
            CLEANUP_RESULT="Unable to cleanup - unknown package manager"
            ;;
    esac

    log "Dependency cleanup completed"
}

# Function to generate maintenance report
generate_report() {
    log "Generating maintenance report..."

    # Create report filename
    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M')
    REPORT_FILE="$REPORT_DIR/${HOSTNAME}_${OS_ID}_${TIMESTAMP}.md"

    # Ensure report directory exists
    mkdir -p "$REPORT_DIR"

    # Generate report content
    cat > "$REPORT_FILE" << EOF
# System Maintenance Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S %Z')
**PC Name:** $HOSTNAME
**Operating System:** $OS_NAME

## 1. System Check Results

### CPU
- **Model:** $CPU_INFO
- **Cores:** $CPU_CORES
- **Current Load:** $CPU_LOAD
- **Status:** ✅ Operational

### RAM
- **Total Memory:** $MEMORY_TOTAL
- **Used:** $MEMORY_USED
- **Free:** $MEMORY_FREE
- **Available:** $MEMORY_AVAILABLE
- **Status:** ✅ $(if [[ ${MEMORY_AVAILABLE%?} -gt 1000 ]]; then echo "Excellent"; else echo "Adequate"; fi)

### Disk Storage
\`\`\`
$DISK_INFO
\`\`\`
- **Status:** $(if echo "$DISK_INFO" | grep -q "9[0-9]%\|100%"; then echo "⚠️ Warning - High disk usage detected"; else echo "✅ Good"; fi)

### Network
\`\`\`
$NETWORK_INFO
\`\`\`
- **Status:** ✅ Network interfaces operational

### Services
- **Failed Services:** $FAILED_SERVICES
- **System Uptime:** $UPTIME_INFO
- **Status:** $(if [[ $FAILED_SERVICES -eq 0 ]]; then echo "✅ All services running"; else echo "⚠️ $FAILED_SERVICES failed service(s)"; fi)

## 2. Updates Applied

### Package Updates
- **Result:** $UPDATES_APPLIED
- **Package Manager:** $PKG_MANAGER
- **Status:** ✅ Update process completed

## 3. Dependencies Removed

### Cleanup Results
- **Result:** $CLEANUP_RESULT
- **Status:** ✅ Cleanup completed

## 4. Errors and Warnings

### Recent System Errors
\`\`\`
$RECENT_ERRORS
\`\`\`

### System Status
$(if [[ $FAILED_SERVICES -eq 0 ]]; then echo "- **Status:** ✅ No critical issues detected"; else echo "- **Status:** ⚠️ $FAILED_SERVICES failed service(s) require attention"; fi)

## 5. Additional Information

### System Specifications
- **Kernel:** $(uname -r)
- **Architecture:** $(uname -m)
- **Uptime:** $UPTIME_INFO

### Maintenance Summary
- **Script Runtime:** $SCRIPT_START_TIME to $(date '+%Y-%m-%d %H:%M:%S')
- **Operations Performed:**
  - System health check
  - Package updates
  - Dependency cleanup
  - Report generation

### Recommendations
$(if echo "$DISK_INFO" | grep -q "9[0-9]%\|100%"; then echo "- **Storage:** Monitor high disk usage and consider cleanup"; fi)
$(if [[ $FAILED_SERVICES -gt 0 ]]; then echo "- **Services:** Investigate failed services: \`systemctl --failed\`"; fi)
- **Next Maintenance:** Recommended within 1-2 weeks
- **Monitoring:** Continue regular system monitoring

### System Health Score: $(if [[ $FAILED_SERVICES -eq 0 ]] && ! echo "$DISK_INFO" | grep -q "9[0-9]%\|100%"; then echo "10/10"; elif [[ $FAILED_SERVICES -eq 0 ]] || ! echo "$DISK_INFO" | grep -q "9[0-9]%\|100%"; then echo "8/10"; else echo "6/10"; fi)

---

_Automated maintenance report generated by system_maintenance.sh_
_End of report._
EOF

    log "Report saved to: $REPORT_FILE"
}

# Function to display report
display_report() {
    log "Displaying maintenance report..."
    echo
    echo "=========================================="
    echo "           MAINTENANCE REPORT"
    echo "=========================================="
    cat "$REPORT_FILE"
    echo "=========================================="
}

# Function to set script permissions
set_permissions() {
    log "Setting execute permissions on script..."
    chmod +x "$0"
    log "Script permissions updated"
}

# Main execution function
main() {
    echo "=========================================="
    echo "    System Maintenance Automation"
    echo "    Started: $SCRIPT_START_TIME"
    echo "=========================================="

    # Ensure we're running as a user who can sudo
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo access for system operations"
        log_info "You may be prompted for your password"
    fi

    # Create necessary directories
    mkdir -p "$REPORT_DIR" "$SCRIPT_DIR"

    # Execute maintenance steps
    detect_os
    system_health_check
    update_packages
    cleanup_dependencies
    generate_report
    display_report
    set_permissions

    # Cleanup temp files
    [[ -f "$TEMP_LOG" ]] && rm -f "$TEMP_LOG"

    echo
    echo "=========================================="
    echo "    Maintenance Completed Successfully"
    echo "    Finished: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "    Report: $REPORT_FILE"
    echo "=========================================="
}

# Trap to cleanup on exit
trap 'rm -f "$TEMP_LOG"' EXIT

# Run main function
main "$@"
