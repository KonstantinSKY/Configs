#!/bin/bash

####################################################################################################
# Script to create a new folder and initialize a private GitHub repository.                        #
# NAME:   make_private_repo.sh                                             CREATED: 2025-07-16 #
# AUTHOR: Stan SKY                                                          EMAIL: info@skyweb3.us #
####################################################################################################

set -e  # Exit on any error

# Enable alias expansion
shopt -s expand_aliases

# Constants
SCRIPT_NAME="make_private_repo.sh"
DEFAULT_PROJECT_NAME="new-project"
PROJECTS_DIR="$(pwd)"
INITIAL_COMMIT_MSG="Initial commit"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
VIOLET='\033[0;35m'
NC='\033[0m' # No Color

# Unified Logging System
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_command() { echo -e "${VIOLET}[CMD]${NC} $1"; }

# Startup Banner Function
print_start_banner() {
    echo "==================================================================="
    echo "🚀 STARTING: $SCRIPT_NAME 🚀"
    echo "==================================================================="
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get project name
get_project_name() {
    local project_name=""

    # Check command line argument
    if [ $# -gt 0 ] && [ -n "$1" ]; then
        project_name="$1"
        echo "$project_name"
        return
    fi

    # Check environment variable
    if [ -n "$PROJECT_NAME" ]; then
        project_name="$PROJECT_NAME"
        echo "$project_name"
        return
    fi

    # Prompt user - send prompt to stderr, read from stdin
    echo -n "Enter project name (or press Enter for default '$DEFAULT_PROJECT_NAME'): " >&2
    read -r user_input

    if [ -z "$user_input" ]; then
        project_name="$DEFAULT_PROJECT_NAME"
    else
        project_name="$user_input"
    fi

    # Validate project name (only alphanumeric, dash, underscore)
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid project name. Only letters, numbers, dashes, and underscores are allowed."
        exit 1
    fi

    echo "$project_name"
}

# Function to check and configure Git user
check_git_config() {
    log_info "Checking Git user configuration..."

    # Check if git user.name is set
    if ! git config --global user.name >/dev/null 2>&1; then
        log_warning "Git user.name not configured"
        echo -n "Enter your Git username: " >&2
        read -r git_username
        log_command "git config --global user.name \"$git_username\""
        git config --global user.name "$git_username"
    fi

    # Check if git user.email is set
    if ! git config --global user.email >/dev/null 2>&1; then
        log_warning "Git user.email not configured"
        echo -n "Enter your Git email: " >&2
        read -r git_email
        log_command "git config --global user.email \"$git_email\""
        git config --global user.email "$git_email"
    fi

    log_success "Git user configured: $(git config --global user.name) <$(git config --global user.email)>"
}

# Function to check SSH connection to GitHub
check_github_ssh() {
    log_info "Verifying SSH access to GitHub..."
    log_command "ssh -T git@github.com -o ConnectTimeout=10 -o StrictHostKeyChecking=no"
    if ssh -T git@github.com -o ConnectTimeout=10 -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
        log_success "SSH access to GitHub verified"
        return 0
    else
        log_error "SSH access to GitHub failed. Please ensure your SSH key is added to GitHub."
        return 1
    fi
}

# Function to delete master branch if it exists
delete_master_branch() {
    log_info "Checking for master branch to delete..."

    # Check if master branch exists locally
    if git show-ref --verify --quiet refs/heads/master; then
        log_info "Deleting local master branch..."
        log_command "git branch -d master"
        git branch -d master 2>/dev/null || log_warning "Could not delete local master branch"
        log_success "Local master branch deleted"
    fi

    # Check if master branch exists on remote
    if git ls-remote --heads origin master | grep -q master; then
        log_info "Deleting remote master branch..."
        log_command "git push origin --delete master"
        git push origin --delete master 2>/dev/null || log_warning "Could not delete remote master branch"
        log_success "Remote master branch deleted"
    fi
}

# Main script execution
main() {
    print_start_banner

    log_info "Starting GitHub private repository creation process..."

    # Step 1: Validate prerequisites
    log_info "Step 1/7: Validating prerequisites..."

    # Check for Git
    if ! command_exists git; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi

    # Check Git configuration
    check_git_config

    # Check if gh CLI is installed
    if ! command_exists gh; then
        log_error "GitHub CLI (gh) is not installed. Please install it first."
        log_info "Install with: yay -S github-cli"
        exit 1
    fi

    # Check if user is authenticated with GitHub CLI
    log_command "gh auth status"
    if ! gh auth status >/dev/null 2>&1; then
        log_error "Not authenticated with GitHub CLI. Please run 'gh auth login' first."
        exit 1
    fi

    # Verify SSH access to GitHub
    if ! check_github_ssh; then
        exit 1
    fi

    log_success "All prerequisites validated"

    # Step 2: Get project name
    log_info "Step 2/7: Determining project name..."
    PROJECT_NAME=$(get_project_name "$@")
    log_success "Project name: $PROJECT_NAME"

    # Step 3: Create project directory in current working directory
    log_info "Step 3/7: Creating project directory in current working directory..."
    PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

    if [ -d "$PROJECT_PATH" ]; then
        log_error "Directory $PROJECT_PATH already exists!"
        exit 1
    fi

    log_command "mkdir -p $PROJECT_NAME"
    mkdir -p "$PROJECT_NAME"
    log_command "cd $PROJECT_NAME"
    cd "$PROJECT_NAME"
    log_success "Project directory created at: $PROJECT_PATH"

    # Step 4: Initialize git repository with main branch
    log_info "Step 4/7: Initializing Git repository with main branch..."
    log_command "git init"
    git init
    log_command "git checkout -b main"
    git checkout -b main

    # Create initial README file
    log_command "echo '# $PROJECT_NAME' > README.md"
    echo "# $PROJECT_NAME" > README.md
    echo "" >> README.md
    echo "Project created on $(date)" >> README.md

    log_success "Git repository initialized with main branch"

    # Step 5: Add files and make initial commit
    log_info "Step 5/7: Adding files and making initial commit..."
    log_command "git add ."
    git add .
    log_command "git commit -m \"$INITIAL_COMMIT_MSG\""
    git commit -m "$INITIAL_COMMIT_MSG"
    log_success "Initial commit created"

    # Step 6: Create private GitHub repository and set up remote
    log_info "Step 6/7: Creating private GitHub repository..."

    log_command "gh repo create $PROJECT_NAME --private --description \"Project: $PROJECT_NAME\""
    gh repo create "$PROJECT_NAME" --private --description "Project: $PROJECT_NAME"

    # Get GitHub username and set up SSH remote
    log_command "gh api user --jq .login"
    GITHUB_USERNAME=$(gh api user --jq .login)
    log_command "git remote add origin git@github.com:$GITHUB_USERNAME/$PROJECT_NAME.git"
    git remote add origin "git@github.com:$GITHUB_USERNAME/$PROJECT_NAME.git"

    # Push to remote
    log_command "git push -u origin main"
    git push -u origin main
    log_success "Private GitHub repository created and code pushed via SSH"

    # Step 7: Clean up and delete master branch if it exists
    log_info "Step 7/7: Cleaning up and deleting master branch if exists..."
    delete_master_branch

    # Generate final report
    log_info "Generating final report..."

    # Get repository URL
    log_command "gh repo view --json url -q .url"
    REPO_URL=$(gh repo view --json url -q .url 2>/dev/null || echo "https://github.com/$GITHUB_USERNAME/$PROJECT_NAME")

    echo
    echo "=========================================="
    echo "      REPOSITORY CREATION COMPLETE       "
    echo "=========================================="
    echo
    log_success "GitHub Repository: $REPO_URL"
    log_success "Local Project Path: $PROJECT_PATH"
    echo
    echo "Environment Information:"
    echo "  - Git Branch: $(git branch --show-current)"
    echo "  - Remote Origin: $(git remote get-url origin)"
    echo "  - Repository Type: Private"
    echo "  - GitHub Username: $GITHUB_USERNAME"
    echo "  - Operating System: Manjaro Linux i3"
    echo "  - Current Working Directory: $(pwd)"
    echo
    echo "Project Structure:"
    if command_exists tree; then
        log_command "tree -L 2 ."
        tree -L 2 .
    else
        log_command "find . -maxdepth 2 -type f | sort"
        find . -maxdepth 2 -type f | sort | sed 's|^\./|  |'
    fi
    echo
    echo "Summary of Actions Performed:"
    echo "  1. ✓ Prerequisites validated (Git, GitHub CLI, SSH access)"
    echo "  2. ✓ Project name determined: $PROJECT_NAME"
    echo "  3. ✓ Directory created in current working directory: $PROJECT_PATH"
    echo "  4. ✓ Git repository initialized with main branch"
    echo "  5. ✓ Initial commit created with README.md"
    echo "  6. ✓ Private GitHub repository created and pushed via SSH"
    echo "  7. ✓ Master branch deleted (if existed)"
    echo
    echo "Next Steps:"
    echo "  1. cd $PROJECT_PATH"
    echo "  2. Start adding your project files"
    echo "  3. git add . && git commit -m 'Your commit message'"
    echo "  4. git push origin main"
    echo
    echo "Repository Details:"
    echo "  - Repository URL: $REPO_URL"
    echo "  - Clone command: git clone git@github.com:$GITHUB_USERNAME/$PROJECT_NAME.git"
    echo "  - Local path: $PROJECT_PATH"
    echo
    log_success "All steps completed successfully!"
}

# Validate arguments
if [ $# -gt 1 ]; then
    log_error "Too many arguments. Usage: $0 [project_name]"
    echo "Examples:"
    echo "  $0                    # Interactive mode"
    echo "  $0 my-project        # With project name"
    echo "  PROJECT_NAME=test $0 # With environment variable"
    exit 1
fi

# Execute main function with all arguments
main "$@"
