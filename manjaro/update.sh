#!/bin/bash

# Manjaro i3 Full System Update Script
# This script performs a comprehensive system update with detailed reporting
# Author: System Administrator
# Date: $(date)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables for tracking
UPDATED_PACKAGES=""
CACHE_CLEANED=false
REBOOT_REQUIRED=false
ORPHANED_REMOVED=0
ERRORS_ENCOUNTERED=""
AUR_PACKAGES_UPDATED=""

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ERRORS_ENCOUNTERED+="$1\n"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user."
        exit 1
    fi
}

# Function to check for running processes that might interfere
check_processes() {
    print_status "Checking for interfering processes..."

    local processes=("pacman" "pamac" "yay" "paru" "makepkg")
    local found_processes=""

    for process in "${processes[@]}"; do
        if pgrep -x "$process" > /dev/null; then
            found_processes+="$process "
        fi
    done

    if [[ -n "$found_processes" ]]; then
        print_error "Found running package management processes: $found_processes"
        print_error "Please close these processes before running the update."
        exit 1
    fi

    # Check if pacman database is locked
    if [[ -f /var/lib/pacman/db.lck ]]; then
        print_error "Pacman database is locked. Another package manager might be running."
        print_error "If you're sure no other package manager is running, remove /var/lib/pacman/db.lck"
        exit 1
    fi

    print_success "No interfering processes found."
}

# Function to synchronize repositories
sync_repositories() {
    print_status "Synchronizing package repositories..."

    if sudo pacman -Sy; then
        print_success "Repositories synchronized successfully."
    else
        print_error "Failed to synchronize repositories."
        exit 1
    fi
}

# Function to update official packages
update_official_packages() {
    print_status "Updating packages from official Manjaro repositories..."

    # Get list of packages that will be updated
    local update_list=$(pacman -Qu 2>/dev/null)

    if [[ -z "$update_list" ]]; then
        print_success "All official packages are up to date."
        return 0
    fi

    print_status "The following packages will be updated:"
    echo "$update_list"

    # Perform the update
    if sudo pacman -Su --noconfirm; then
        UPDATED_PACKAGES="$update_list"
        print_success "Official packages updated successfully."

        # Check if kernel was updated
        if echo "$update_list" | grep -q "^linux"; then
            print_warning "Kernel was updated. A reboot will be required."
            REBOOT_REQUIRED=true
        fi
    else
        print_error "Failed to update official packages."
        exit 1
    fi
}

# Function to check for AUR helper and update AUR packages
update_aur_packages() {
    print_status "Checking for AUR packages to update..."

    # Check for available AUR helpers
    local aur_helper=""
    if command -v yay &> /dev/null; then
        aur_helper="yay"
    elif command -v paru &> /dev/null; then
        aur_helper="paru"
    elif command -v pamac &> /dev/null; then
        aur_helper="pamac"
    else
        print_warning "No AUR helper found. Skipping AUR package updates."
        return 0
    fi

    print_status "Using $aur_helper to check for AUR updates..."

    case $aur_helper in
        "yay")
            local aur_updates=$(yay -Qua 2>/dev/null)
            if [[ -n "$aur_updates" ]]; then
                print_status "Found AUR packages to update:"
                echo "$aur_updates"
                if yay -Sua --noconfirm; then
                    AUR_PACKAGES_UPDATED="$aur_updates"
                    print_success "AUR packages updated successfully."
                else
                    print_error "Failed to update some AUR packages."
                fi
            else
                print_success "All AUR packages are up to date."
            fi
            ;;
        "paru")
            if paru -Sua --noconfirm; then
                print_success "AUR packages checked and updated with paru."
            else
                print_error "Failed to update AUR packages with paru."
            fi
            ;;
        "pamac")
            if pamac upgrade --aur --no-confirm; then
                print_success "AUR packages updated with pamac."
            else
                print_error "Failed to update AUR packages with pamac."
            fi
            ;;
    esac
}

# Function to check if reboot is required
check_reboot_required() {
    print_status "Checking if reboot is required..."

    # Check for kernel updates
    if [[ -f /usr/lib/modules/$(uname -r)/modules.dep ]]; then
        local running_kernel=$(uname -r)
        local installed_kernels=$(ls /usr/lib/modules/ | grep -v "$running_kernel" | head -1)

        if [[ -n "$installed_kernels" ]] || [[ "$REBOOT_REQUIRED" == true ]]; then
            REBOOT_REQUIRED=true
            print_warning "Reboot is required due to kernel updates."
        fi
    fi

    # Check for updated system libraries
    if command -v needrestart &> /dev/null; then
        if needrestart -r l | grep -q "NEEDRESTART-KSTA: 1"; then
            REBOOT_REQUIRED=true
            print_warning "Reboot is required due to system library updates."
        fi
    fi

    # Check for systemd updates
    if systemctl status | grep -q "degraded"; then
        print_warning "Some systemd services may need restart. Check with 'systemctl --failed'"
    fi
}

# Function to remove orphaned packages
remove_orphaned_packages() {
    print_status "Checking for orphaned packages..."

    local orphaned=$(pacman -Qtdq 2>/dev/null)

    if [[ -z "$orphaned" ]]; then
        print_success "No orphaned packages found."
        return 0
    fi

    print_status "Found orphaned packages:"
    echo "$orphaned"

    # Count orphaned packages
    ORPHANED_REMOVED=$(echo "$orphaned" | wc -l)

    print_warning "About to remove $ORPHANED_REMOVED orphaned packages. Reviewing packages for safety..."

    # Check for potentially important packages
    local important_packages="nvidia docker virtualbox"
    local risky_packages=""

    for pkg in $orphaned; do
        for important in $important_packages; do
            if echo "$pkg" | grep -q "$important"; then
                risky_packages+="$pkg "
            fi
        done
    done

    if [[ -n "$risky_packages" ]]; then
        print_warning "Found potentially important orphaned packages: $risky_packages"
        print_warning "Please review these packages manually before removal."
        print_status "Skipping automatic removal of orphaned packages for safety."
        ORPHANED_REMOVED=0
        return 0
    fi

    # Remove orphaned packages
    if sudo pacman -Rns --noconfirm $orphaned; then
        print_success "Removed $ORPHANED_REMOVED orphaned packages."
    else
        print_error "Failed to remove some orphaned packages."
        ORPHANED_REMOVED=0
    fi
}

# Function to clean package cache
clean_package_cache() {
    print_status "Cleaning package cache..."

    # Clean old packages from cache, keeping the latest 3 versions
    if sudo paccache -rk3; then
        print_success "Package cache cleaned (kept 3 most recent versions)."
        CACHE_CLEANED=true
    else
        print_error "Failed to clean package cache."
    fi

    # Clean uninstalled packages from cache
    if sudo paccache -ruk0; then
        print_success "Removed cached packages that are no longer installed."
    else
        print_error "Failed to clean uninstalled packages from cache."
    fi
}

# Function to remove unused dependencies
remove_unused_dependencies() {
    print_status "Checking for unused dependencies..."

    # This is handled by the orphaned packages removal
    print_success "Unused dependencies check completed with orphaned packages removal."
}

# Function to verify system integrity
verify_system_integrity() {
    print_status "Verifying system integrity..."

    # Check for broken packages
    if ! pacman -Qk 2>/dev/null | grep -q "warning"; then
        print_success "No broken packages detected."
    else
        print_warning "Some package files may be missing or corrupted. Run 'pacman -Qk' for details."
    fi

    # Check disk space
    local available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # Less than 1GB
        print_warning "Low disk space detected. Consider cleaning up unnecessary files."
    fi
}

# Function to print final summary
print_summary() {
    echo ""
    echo "=========================================="
    echo "           UPDATE SUMMARY REPORT"
    echo "=========================================="
    echo ""

    # Updated packages
    if [[ -n "$UPDATED_PACKAGES" ]]; then
        echo -e "${GREEN}Official Packages Updated:${NC}"
        echo "$UPDATED_PACKAGES" | head -20
        local package_count=$(echo "$UPDATED_PACKAGES" | wc -l)
        if [[ $package_count -gt 20 ]]; then
            echo "... and $((package_count - 20)) more packages"
        fi
        echo ""
    else
        echo -e "${GREEN}Official Packages:${NC} All packages were already up to date"
        echo ""
    fi

    # AUR packages
    if [[ -n "$AUR_PACKAGES_UPDATED" ]]; then
        echo -e "${GREEN}AUR Packages Updated:${NC}"
        echo "$AUR_PACKAGES_UPDATED"
        echo ""
    else
        echo -e "${GREEN}AUR Packages:${NC} No updates available or no AUR helper found"
        echo ""
    fi

    # Cache status
    if [[ "$CACHE_CLEANED" == true ]]; then
        echo -e "${GREEN}Package Cache:${NC} Cleaned successfully"
    else
        echo -e "${YELLOW}Package Cache:${NC} Not cleaned"
    fi
    echo ""

    # Reboot requirement
    if [[ "$REBOOT_REQUIRED" == true ]]; then
        echo -e "${YELLOW}Reboot Required:${NC} YES - Please reboot your system"
    else
        echo -e "${GREEN}Reboot Required:${NC} NO"
    fi
    echo ""

    # Orphaned packages
    echo -e "${GREEN}Orphaned Packages Removed:${NC} $ORPHANED_REMOVED"
    echo ""

    # System status
    if [[ -z "$ERRORS_ENCOUNTERED" ]]; then
        echo -e "${GREEN}Overall Status:${NC} Update completed successfully"
    else
        echo -e "${YELLOW}Overall Status:${NC} Update completed with some issues"
        echo ""
        echo -e "${RED}Errors Encountered:${NC}"
        echo -e "$ERRORS_ENCOUNTERED"
    fi

    echo "=========================================="
    echo ""

    # Additional recommendations
    if [[ "$REBOOT_REQUIRED" == true ]]; then
        echo -e "${YELLOW}RECOMMENDATION:${NC} Please reboot your system to complete the update process."
        echo "You can reboot now with: sudo reboot"
        echo ""
    fi

    echo "Update completed at: $(date)"
}

# Main execution function
main() {
    echo "=========================================="
    echo "    Manjaro i3 System Update Script"
    echo "=========================================="
    echo "Started at: $(date)"
    echo ""

    # Pre-flight checks
    check_root
    check_processes

    # Update process
    sync_repositories
    update_official_packages
    update_aur_packages
    check_reboot_required

    # Cleanup process
    remove_orphaned_packages
    clean_package_cache
    remove_unused_dependencies

    # Final checks
    verify_system_integrity

    # Report results
    print_summary
}

# Trap to handle script interruption
trap 'print_error "Script interrupted by user"; exit 1' INT TERM

# Execute main function
main "$@"
