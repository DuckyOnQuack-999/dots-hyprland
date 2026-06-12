#!/bin/bash
# update-workflow.sh - Git workflow for managing end-4's dots-hyprland with local changes
# 
# This script helps you keep your local changes when upstream updates.
# It uses a branch-based workflow where:
# - 'main' tracks upstream/main
# - 'my-changes' contains your local modifications
# - You merge upstream changes into 'my-changes' when needed

set -e

REPO_DIR="/home/duckyonquack999/GitHub-Repositories/dots-hyprland"
UPSTREAM_REMOTE="upstream"
LOCAL_BRANCH="quickshell-extended"
UPSTREAM_BRANCH="main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -d "$REPO_DIR/.git" ]; then
    log_error "Repository not found at $REPO_DIR"
    exit 1
fi

cd "$REPO_DIR"

# Function to show current status
show_status() {
    log_info "Current repository status:"
    echo "  Repository: $REPO_DIR"
    echo "  Current branch: $(git branch --show-current)"
    echo "  Upstream remote: $UPSTREAM_REMOTE"
    echo "  Upstream branch: $UPSTREAM_BRANCH"
    echo "  Local branch: $LOCAL_BRANCH"
    echo "  🎨 Quickshell extensions active!"
    echo ""
}

# Function to fetch upstream changes
fetch_upstream() {
    log_info "Fetching upstream changes..."
    git fetch $UPSTREAM_REMOTE
    log_success "Upstream changes fetched"
}

# Function to show what's new in upstream
show_upstream_changes() {
    log_info "Changes in upstream since last merge:"
    git log --oneline --graph --decorate $LOCAL_BRANCH..$UPSTREAM_REMOTE/$UPSTREAM_BRANCH | head -20
    echo ""
}

# Function to merge upstream changes
merge_upstream() {
    log_info "Merging upstream changes into $LOCAL_BRANCH..."
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "You have uncommitted changes. Please commit or stash them first."
        git status --short
        return 1
    fi
    
    # Merge upstream changes
    git merge $UPSTREAM_REMOTE/$UPSTREAM_BRANCH --no-edit
    
    if [ $? -eq 0 ]; then
        log_success "Upstream changes merged successfully"
    else
        log_error "Merge conflict detected. Please resolve conflicts manually."
        log_info "Run 'git status' to see conflicting files"
        log_info "After resolving, run 'git add <files>' and 'git commit'"
        return 1
    fi
}

# Function to rebase instead of merge (cleaner history)
rebase_upstream() {
    log_info "Rebasing $LOCAL_BRANCH onto upstream/$UPSTREAM_BRANCH..."
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "You have uncommitted changes. Please commit or stash them first."
        git status --short
        return 1
    fi
    
    # Rebase onto upstream
    git rebase $UPSTREAM_REMOTE/$UPSTREAM_BRANCH
    
    if [ $? -eq 0 ]; then
        log_success "Rebase completed successfully"
    else
        log_error "Rebase conflict detected. Please resolve conflicts manually."
        log_info "Run 'git status' to see conflicting files"
        log_info "After resolving, run 'git add <files>' and 'git rebase --continue'"
        return 1
    fi
}

# Function to push local changes (if you have a fork)
push_changes() {
    log_info "Pushing local changes to origin..."
    
    # Check if origin remote exists
    if git remote | grep -q "^origin$"; then
        git push origin $LOCAL_BRANCH
        log_success "Changes pushed to origin"
    else
        log_warning "No 'origin' remote configured. You need to fork the repository on GitHub first."
        log_info "To add your fork as origin: git remote add origin https://github.com/YOUR_USERNAME/dots-hyprland.git"
    fi
}

# Function to create a backup of current state
backup_state() {
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup branch: $backup_name"
    git branch $backup_name
    log_success "Backup created: $backup_name"
}

# Function to show help
show_help() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║           🎨 Quickshell Extended - Git Workflow Manager 🎨                  ║"
    echo "║              Managing end-4's dots-hyprland with style!                     ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status       - Show current repository status"
    echo "  fetch        - Fetch upstream changes"
    echo "  show-changes - Show what's new in upstream"
    echo "  merge        - Merge upstream changes into local branch"
    echo "  rebase       - Rebase local branch onto upstream (cleaner history)"
    echo "  push         - Push local changes to origin (requires fork)"
    echo "  backup       - Create a backup branch of current state"
    echo "  help         - Show this help message"
    echo ""
    echo "Workflow:"
    echo "  1. Make your changes and commit them to '$LOCAL_BRANCH' branch"
    echo "  2. When upstream updates, run: $0 fetch && $0 show-changes"
    echo "  3. Then run: $0 merge  (or $0 rebase for cleaner history)"
    echo "  4. Resolve any conflicts if they occur"
    echo "  5. Optionally push to your fork: $0 push"
    echo ""
    echo "Pro Tips:"
    echo "  • Use 'rebase' for cleaner git history"
    echo "  • Create backups before major merges: $0 backup"
    echo "  • Fork the repo on GitHub to enable 'push' command"
    echo "  • Your Quickshell extensions live in the 'dots' directory"
}

# Main command handling
case "${1:-help}" in
    status)
        show_status
        ;;
    fetch)
        fetch_upstream
        ;;
    show-changes)
        fetch_upstream
        show_upstream_changes
        ;;
    merge)
        fetch_upstream
        merge_upstream
        ;;
    rebase)
        fetch_upstream
        rebase_upstream
        ;;
    push)
        push_changes
        ;;
    backup)
        backup_state
        ;;
    help|*)
        show_help
        ;;
esac