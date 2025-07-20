#!/bin/bash

####################################################################################################
# Install Rust programming language and development environment on Manjaro Linux                  #
# NAME:   install.sh                                                           CREATED: 2025-07-16 #
# AUTHOR: Stan SKY                                                          EMAIL: info@skyweb3.us #
####################################################################################################

set -e

# Constants Block
SCRIPT_NAME="install.sh"
PROJECT_DIR="$HOME/Work/Configs/rust"
RUST_PACKAGES=("rust" "rustc" "cargo")
RUST_DEV_TOOLS=("rust-analyzer" "cargo-edit" "cargo-make" "cargo-watch")
BUILD_TOOLS=("base-devel" "curl")

# Color definitions for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
VIOLET='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_command() { echo -e "${VIOLET}[CMD]${NC} $1"; }

# Startup banner function
print_start_banner() {
    echo "==================================================================="
    echo "🚀 STARTING: $SCRIPT_NAME 🚀"
    echo "==================================================================="
}

# Function to check if a package is installed
is_package_installed() {
    local package=$1
    yay -Qi "$package" &>/dev/null
}

# Function to get installed package version
get_package_version() {
    local package=$1
    yay -Qi "$package" 2>/dev/null | grep "Version" | awk '{print $3}' | head -1
}

# Function to get available package version
get_available_version() {
    local package=$1
    yay -Si "$package" 2>/dev/null | grep "Version" | awk '{print $3}' | head -1
}

# Function to ask user for confirmation
ask_user_confirmation() {
    local prompt=$1
    local response
    while true; do
        read -p "$prompt (yes/no): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Function to install packages
install_packages() {
    local packages=("$@")
    log_info "Installing packages: ${packages[*]}"
    log_command "yay -S --noconfirm ${packages[*]}"
    yay -S --noconfirm "${packages[@]}"
}

# Function to update packages
update_packages() {
    local packages=("$@")
    log_info "Updating packages: ${packages[*]}"
    log_command "yay -S --noconfirm ${packages[*]}"
    yay -S --noconfirm "${packages[@]}"
}

# Function to check and install Rust
check_and_install_rust() {
    local rust_installed=true
    local missing_packages=()

    log_info "Checking Rust installation status..."

    # Check each Rust component
    for package in "${RUST_PACKAGES[@]}"; do
        if ! is_package_installed "$package"; then
            rust_installed=false
            missing_packages+=("$package")
        fi
    done

    if [ "$rust_installed" = false ]; then
        log_warning "Rust is not fully installed. Missing packages: ${missing_packages[*]}"
        log_info "Installing Rust via yay..."
        install_packages "${missing_packages[@]}"

        # Source cargo environment if available
        if [ -f "$HOME/.cargo/env" ]; then
            log_info "Sourcing Rust environment..."
            log_command "source ~/.cargo/env"
            source "$HOME/.cargo/env"
        fi

        log_success "Rust installation completed!"
    else
        log_success "Rust is already installed"

        # Check for updates
        log_info "Checking for Rust updates..."
        local needs_update=false
        local update_packages=()

        for package in "${RUST_PACKAGES[@]}"; do
            local current_version=$(get_package_version "$package")
            local available_version=$(get_available_version "$package")

            echo "Package: $package"
            echo "  Current version: $current_version"
            echo "  Available version: $available_version"

            if [ "$current_version" != "$available_version" ] && [ -n "$available_version" ]; then
                needs_update=true
                update_packages+=("$package")
            fi
        done

        if [ "$needs_update" = true ]; then
            log_warning "Updates available for: ${update_packages[*]}"
            if ask_user_confirmation "Do you want to upgrade Rust?"; then
                update_packages "${update_packages[@]}"
                log_success "Rust upgrade completed!"

                # Reload environment
                if [ -f "$HOME/.cargo/env" ]; then
                    log_info "Reloading Rust environment..."
                    source "$HOME/.cargo/env"
                fi
            else
                log_info "Rust upgrade skipped by user"
            fi
        else
            log_success "Rust is up to date"
        fi
    fi
}

# Function to check and install development tools
check_and_install_dev_tools() {
    log_info "Checking Rust development tools..."

    local missing_tools=()

    for tool in "${RUST_DEV_TOOLS[@]}"; do
        if ! is_package_installed "$tool"; then
            missing_tools+=("$tool")
        else
            local version=$(get_package_version "$tool")
            log_success "$tool is installed (version: $version)"
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warning "Missing development tools: ${missing_tools[*]}"
        if ask_user_confirmation "Do you want to install missing Rust development tools?"; then
            install_packages "${missing_tools[@]}"
            log_success "Development tools installation completed!"
        else
            log_info "Development tools installation skipped by user"
        fi
    else
        log_success "All Rust development tools are installed"
    fi
}

# Function to check and install build tools
check_and_install_build_tools() {
    log_info "Checking system build tools..."

    local missing_build_tools=()

    for tool in "${BUILD_TOOLS[@]}"; do
        if ! is_package_installed "$tool"; then
            missing_build_tools+=("$tool")
        else
            local version=$(get_package_version "$tool")
            log_success "$tool is installed (version: $version)"
        fi
    done

    if [ ${#missing_build_tools[@]} -gt 0 ]; then
        log_warning "Missing build tools: ${missing_build_tools[*]}"
        if ask_user_confirmation "Do you want to install missing build tools?"; then
            install_packages "${missing_build_tools[@]}"
            log_success "Build tools installation completed!"
        else
            log_info "Build tools installation skipped by user"
        fi
    else
        log_success "All build tools are installed"
    fi
}

# Function to display final versions
display_final_versions() {
    log_info "Final installation summary:"

    echo ""
    echo "=== RUST INSTALLATION SUMMARY ==="

    # Rust components
    for package in "${RUST_PACKAGES[@]}"; do
        if is_package_installed "$package"; then
            local version=$(get_package_version "$package")
            echo "✓ $package: $version"
        else
            echo "✗ $package: NOT INSTALLED"
        fi
    done

    echo ""
    echo "=== DEVELOPMENT TOOLS ==="

    # Development tools
    for tool in "${RUST_DEV_TOOLS[@]}"; do
        if is_package_installed "$tool"; then
            local version=$(get_package_version "$tool")
            echo "✓ $tool: $version"
        else
            echo "✗ $tool: NOT INSTALLED"
        fi
    done

    echo ""
    echo "=== BUILD TOOLS ==="

    # Build tools
    for tool in "${BUILD_TOOLS[@]}"; do
        if is_package_installed "$tool"; then
            local version=$(get_package_version "$tool")
            echo "✓ $tool: $version"
        else
            echo "✗ $tool: NOT INSTALLED"
        fi
    done

    echo ""
    echo "=== CARGO ENVIRONMENT ==="
    if command -v cargo &>/dev/null; then
        echo "✓ Cargo is available in PATH"
        echo "✓ Cargo version: $(cargo --version)"
        echo "✓ Rustc version: $(rustc --version)"
    else
        echo "✗ Cargo is not available in PATH"
        echo "  You may need to restart your shell or run: source ~/.cargo/env"
    fi
}

# Function to generate final report
generate_final_report() {
    echo ""
    echo "=================================================================="
    echo "🎯 RUST ENVIRONMENT INSTALLATION REPORT"
    echo "=================================================================="
    echo ""
    echo "STEPS PERFORMED:"
    echo "1. ✓ Checked Rust installation status (rust, rustc, cargo)"
    echo "2. ✓ Handled Rust installation/updates via yay package manager"
    echo "3. ✓ Checked and installed Rust development tools"
    echo "4. ✓ Verified system build tools availability"
    echo "5. ✓ Generated comprehensive installation summary"
    echo ""

    display_final_versions

    echo ""
    echo "NEXT STEPS:"
    echo "• Restart your terminal or run 'source ~/.cargo/env' to ensure PATH is updated"
    echo "• Test your installation with: cargo --version"
    echo "• Create a new Rust project with: cargo new hello_world"
    echo "• Configure your IDE/editor to use rust-analyzer for better development experience"
    echo ""
    echo "PROJECT DIRECTORY: $PROJECT_DIR"
    echo "SCRIPT LOCATION: $PROJECT_DIR/$SCRIPT_NAME"
    echo ""
    echo "=================================================================="
    log_success "Rust environment setup completed successfully!"
    echo "=================================================================="
}

# Main execution
main() {
    print_start_banner

    log_info "Starting Rust environment installation and verification..."
    log_info "Project directory: $PROJECT_DIR"

    # Update package database
    log_info "Updating package database..."
    log_command "yay -Sy"
    yay -Sy

    # Step 1: Check and install Rust
    check_and_install_rust

    # Step 2: Check and install development tools
    check_and_install_dev_tools

    # Step 3: Check and install build tools
    check_and_install_build_tools

    # Step 4: Generate final report
    generate_final_report
}

# Execute main function
main "$@"
