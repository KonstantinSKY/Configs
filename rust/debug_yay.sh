#!/bin/bash

####################################################################################################
# Debug script to test yay commands individually to identify hanging issues                        #
# NAME:   debug_yay.sh                                                         CREATED: 2025-07-16 #
# AUTHOR: Stan SKY                                                          EMAIL: info@skyweb3.us #
####################################################################################################

set -e

SCRIPT_NAME="debug_yay.sh"

# Color constants for logging
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

print_start_banner() {
    echo "==================================================================="
    echo "🚀 STARTING: $SCRIPT_NAME 🚀"
    echo "==================================================================="
}

test_yay_command() {
    local cmd="$1"
    local timeout_duration="${2:-10}"

    log_info "Testing: $cmd (timeout: ${timeout_duration}s)"
    log_command "timeout $timeout_duration $cmd"

    if timeout "$timeout_duration" $cmd > /dev/null 2>&1; then
        log_success "Command succeeded"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_error "Command timed out after ${timeout_duration}s"
        else
            log_error "Command failed with exit code: $exit_code"
        fi
        return 1
    fi
}

main() {
    print_start_banner

    # Test basic yay functionality
    log_info "Testing basic yay commands..."

    # Test 1: Check if yay is working
    test_yay_command "yay --version" 5

    # Test 2: Check rust installation
    test_yay_command "yay -Qs rust" 10

    # Test 3: Check for rust updates
    test_yay_command "yay -Qu rust" 15

    # Test 4: Check individual tools
    local tools=("rust-analyzer" "cargo-edit" "base-devel" "curl")

    for tool in "${tools[@]}"; do
        log_info "Testing tool: $tool"
        test_yay_command "yay -Qs $tool" 10
    done

    # Test 5: Search for tools
    log_info "Testing search functionality..."
    test_yay_command "yay -Ss cargo-edit" 15

    log_success "All tests completed!"
}

main "$@"
