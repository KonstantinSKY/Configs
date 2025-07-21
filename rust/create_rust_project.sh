#!/bin/bash
####################################################################################################
# Script to create a new Rust project and a private GitHub repository.                             #
# NAME:   create_rust_project.sh                                               CREATED: 2025-07-19 #
# AUTHOR: Stan SKY                                                          EMAIL: info@skyweb3.us #
####################################################################################################

SCRIPT_NAME="create_rust_project.sh"

# --- Constants ---
PROJECTS_DIR="$HOME/Projects"
GITIGNORE_SOURCE="$HOME/Configs/rust/gitignore"
DEFAULT_PROJECT_NAME="rust-new-project"

# --- Colors and Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
VIOLET='\033[0;35m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_command() { echo -e "${VIOLET}[CMD]${NC} $1"; }

# --- Banners ---
print_start_banner() {
    echo "==================================================================="
    echo " 🚀 STARTING: $SCRIPT_NAME 🚀"
    echo "==================================================================="
}

# --- Main Logic ---
main() {
    set -e
    print_start_banner

    # 1. System Update Requirement
    log_info "Checking for yay package manager..."
    if ! command -v yay &> /dev/null; then
        log_warning "yay not found. Installing..."
        log_command "sudo pacman -S --noconfirm yay"
        sudo pacman -S --noconfirm yay
        log_success "yay installed successfully."
    else
        log_success "yay is already installed."
    fi

    log_info "Performing full system update with yay..."
    log_command "yay -Syu --noconfirm"
    yay -Syu --noconfirm
    log_success "System update complete."

    # 2. Check and Prepare Rust Environment
    log_info "Checking Rust environment..."
    if ! command -v rustc &> /dev/null; then
        log_warning "Rust is not installed. Installing with rustup..."
        log_command "yay -S --noconfirm rustup"
        yay -S --noconfirm rustup
        rustup default stable
        log_success "Rust installed successfully."
    else
        log_success "Rust is already installed."
        log_info "Updating Rust environment..."
        log_success "Rust environment updated."
    fi
    log_command "rustc --version && cargo --version"
    rustc --version
    cargo --version

    # 3. Project Name
    if [ -n "$1" ]; then
        PROJECT_NAME="$1"
        log_info "Project name provided via argument: $PROJECT_NAME"
    else
        read -p "Enter the project name (default: ${DEFAULT_PROJECT_NAME}): " PROJECT_NAME
        if [ -z "$PROJECT_NAME" ]; then
            PROJECT_NAME=$DEFAULT_PROJECT_NAME
            log_info "No project name entered, using default: $PROJECT_NAME"
        fi
    fi

    PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"
    REPO_URL="https://github.com/Stan-SKY/$PROJECT_NAME"

    # 4. Create Project Directory
    if [ -d "$PROJECT_PATH" ]; then
        log_error "Project directory '$PROJECT_PATH' already exists. Aborting."
        exit 1
    fi
    log_info "Creating new Rust project at '$PROJECT_PATH'..."
    log_command "cargo new --vcs none "$PROJECT_PATH""
    cargo new --vcs none "$PROJECT_PATH"
    cd "$PROJECT_PATH"
    log_success "Project '$PROJECT_NAME' created."

    # 5. Initialize Version Control
    log_info "Initializing Git repository..."
    log_command "git init -b main"
    git init -b main
    log_command "git add ."
    git add .
    log_command "git commit -m "Initial commit""
    git commit -m "Initial commit"
    log_success "Git repository initialized and initial commit created."

    # 6. GitHub Repository
    log_info "Creating private GitHub repository '$PROJECT_NAME'..."
    if ! command -v gh &> /dev/null; then
        log_error "'gh' command not found. Please install the GitHub CLI and authenticate."
        exit 1
    fi
    log_command "gh repo create "$PROJECT_NAME" --private --source=. --remote=origin"
    gh repo create "$PROJECT_NAME" --private --source=. --remote=origin
    log_success "Private GitHub repository created."

    log_info "Pushing initial commit to remote 'origin'..."
    log_command "git push -u origin main"
    git push -u origin main
    log_success "Initial commit pushed to GitHub."

    # 7. Copy .gitignore from Template
    log_info "Copying .gitignore from template..."
    if [ -f "$GITIGNORE_SOURCE" ]; then
        log_command "cp "$GITIGNORE_SOURCE" ./.gitignore"
        cp "$GITIGNORE_SOURCE" ./.gitignore
        log_command "git add .gitignore"
        git add .gitignore
        log_command "git commit -m "feat: Add custom .gitignore""
        git commit -m "feat: Add custom .gitignore"
        log_command "git push"
        git push --set-upstream origin main
        log_success "Custom .gitignore copied, committed, and pushed."
    else
        log_warning "Custom .gitignore not found at '$GITIGNORE_SOURCE'. Skipping."
    fi

    # 8. Report Results
    echo "==================================================================="
    log_success "🚀 Project setup complete! 🚀"
    echo "-------------------------------------------------------------------"
    log_info "Local Project Path: $PROJECT_PATH"
    log_info "GitHub Repository URL: $REPO_URL"
    echo "==================================================================="
}

main "$@"
