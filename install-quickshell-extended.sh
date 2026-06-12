#!/bin/bash
# install-quickshell-extended.sh - Installation script for Quickshell Extended
# 
# This script sets up your Quickshell extensions for end-4's dots-hyprland
# 
# Usage: ./install-quickshell-extended.sh [OPTIONS]
#
# Options:
#   --help          Show help message
#   --backup        Create backup before installation
#   --force         Force installation (overwrite existing files)
#   --dry-run       Show what will be installed without making changes
#
# Environment variables:
#   DOTFILES_DIR    Directory containing dotfiles (default: ./dots)
#   CONFIG_DIR      Quickshell config directory (default: ~/.config/quickshell)
#   BACKUP_DIR      Backup directory (default: ~/.backup/dots-hyprland)
#
# This script will:
# 1. Create necessary directories
# 2. Copy Quickshell extensions from dots/ to ~/.config/quickshell/
# 3. Set up symlinks for configuration files
# 4. Create necessary scripts and tools
# 5. Set up git workflow for future updates
#
# Note: This script assumes you have already set up the git workflow
# using the update-workflow.sh script.

set -e

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dots"
CONFIG_DIR="$HOME/.config/quickshell"
BACKUP_DIR="$HOME/.backup/dots-hyprland"
WORKFLOW_SCRIPT="$REPO_DIR/update-workflow.sh"
QS_WORKFLOW_SCRIPT="$REPO_DIR/qs-workflow.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Show help message
show_help() {
    cat << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🎨 Quickshell Extended Installer 🎨                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

Usage: $0 [OPTIONS]

Options:
  --help          Show this help message
  --backup        Create backup before installation
  --force         Force installation (overwrite existing files)
  --dry-run       Show what will be installed without making changes

Environment variables:
  DOTFILES_DIR    Directory containing dotfiles (default: ./dots)
  CONFIG_DIR      Quickshell config directory (default: ~/.config/quickshell)
  BACKUP_DIR      Backup directory (default: ~/.backup/dots-hyprland)

This script will:
1. Create necessary directories
2. Copy Quickshell extensions from dots/ to ~/.config/quickshell/
3. Set up symlinks for configuration files
4. Create necessary scripts and tools
5. Set up git workflow for future updates

Note: This script assumes you have already set up the git workflow
using the update-workflow.sh script.

Examples:
  $0                    # Install Quickshell extensions
  $0 --backup           # Backup existing configs before installing
  $0 --force             # Force install (overwrite existing files)
  $0 --dry-run           # Show what will be installed

EOF
}

# Check if dotfiles directory exists
check_dotfiles_dir() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        log_info "Please ensure the 'dots' directory exists in the repository"
        exit 1
    fi
}

# Create backup if requested
create_backup() {
    log_info "Creating backup of existing Quickshell configuration..."
    
    mkdir -p "$BACKUP_DIR"
    local timestamp="$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/backup-$timestamp"
    
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$backup_path/"
        log_success "Backup created at $backup_path"
    else
        log_info "No existing Quickshell configuration found to backup"
    fi
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    mkdir -p "$CONFIG_DIR/modules"
    mkdir -p "$CONFIG_DIR/components"
    mkdir -p "$CONFIG_DIR/services"
    mkdir -p "$CONFIG_DIR/themes"
    mkdir -p "$HOME/.local/bin"
    
    log_success "Directories created"
}

# Copy Quickshell extensions
copy_extensions() {
    log_info "Copying Quickshell extensions..."
    
    # Copy modules
    if [ -d "$DOTFILES_DIR/.config/quickshell/modules" ]; then
        cp -r "$DOTFILES_DIR/.config/quickshell/modules/" "$CONFIG_DIR/"
        log_success "Modules copied"
    fi
    
    # Copy components
    if [ -d "$DOTFILES_DIR/.config/quickshell/components" ]; then
        cp -r "$DOTFILES_DIR/.config/quickshell/components/" "$CONFIG_DIR/"
        log_success "Components copied"
    fi
    
    # Copy services
    if [ -d "$DOTFILES_DIR/.config/quickshell/services" ]; then
        cp -r "$DOTFILES_DIR/.config/quickshell/services/" "$CONFIG_DIR/"
        log_success "Services copied"
    fi
    
    # Copy themes
    if [ -d "$DOTFILES_DIR/.config/quickshell/themes" ]; then
        cp -r "$DOTFILES_DIR/.config/quickshell/themes/" "$CONFIG_DIR/"
        log_success "Themes copied"
    fi
    
    # Copy shell.qml if it exists
    if [ -f "$DOTFILES_DIR/.config/quickshell/shell.qml" ]; then
        cp "$DOTFILES_DIR/.config/quickshell/shell.qml" "$CONFIG_DIR/"
        log_success "shell.qml copied"
    fi
}

# Set up symlinks for configuration files
setup_symlinks() {
    log_info "Setting up symlinks..."
    
    # Create symlinks for configuration files
    if [ -f "$DOTFILES_DIR/.config/quickshell/config.json" ]; then
        ln -sf "$DOTFILES_DIR/.config/quickshell/config.json" "$CONFIG_DIR/config.json"
        log_success "Symlink created for config.json"
    fi
    
    if [ -f "$DOTFILES_DIR/.config/quickshell/settings.json" ]; then
        ln -sf "$DOTFILES_DIR/.config/quickshell/settings.json" "$CONFIG_DIR/settings.json"
        log_success "Symlink created for settings.json"
    fi
}

# Create necessary scripts
create_scripts() {
    log_info "Creating necessary scripts..."
    
    # Create a script to reload Quickshell
    cat > "$HOME/.local/bin/reload-quickshell" << 'EOF'
#!/bin/bash
# Reload Quickshell configuration

CONFIG_DIR="$HOME/.config/quickshell"

# Reload Quickshell
if command -v quickshell >/devdev/null 2>&1; then
    quickshell --reload
    echo "Quickshell reloaded successfully"
else
    echo "Quickshell not found in PATH"
    exit 1
fi
EOF
    
    chmod +x "$HOME/.local/bin/reload-qus"
    log_success "reload-quickshell script created"
    
    # Add to PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        log_success "Added ~/.local/bin to PATH"
    fi
}

# Set up git workflow
setup_git_workflow() {
    log_info "Setting up git workflow..."
    
    # Check if update-workflow.sh exists
    if [ -f "$WORKFLOW_SCRIPT" ]; then
        log_success "update-workflow.sh found"
        
        # Make it executable
        chmod +x "$WORKFLOW_SCRIPT"
        
        # Check if qs-workflow.sh exists
        if [ -f "$QS_WORKFLOW_SCRIPT" ]; then
            log_success "qs-workflow.sh found"
            
            # Source it in shell config files
            if ! grep -q "qs-workflow.sh" "$HOME/.bashrc"; then
                echo "# Quickshell workflow" >> "$HOME/.bashrc"
                echo "source $QS_WORKFLOW_SCRIPT" >> "$HOME/.bashrc"
                log_success "Added qs-workflow.sh to ~/.bashrc"
            fi
            
            if ! grep -q "qs-workflow.sh" "$HOME/.zshrc"; then
                echo "# Quickshell workflow" >> "$HOME/.zshrc"
                echo "source $QS_WORKFLOW_SCRIPT" >> "$HOME/.zshrc"
                log_success "Added qs-workflow.sh to ~/.zshrc"
            fi
        else
            log_warning "qs-workflow.sh not found"
        fi
    else
        log_error "update-workflow.sh not found"
    fi
}

# Install Quickshell extensions
install_extensions() {
    log_info "Installing Quickshell extensions..."
    
    # Check if we should force install
    local force_install=false
    if [[ "$1" == "--force" ]]; then
        force_install=true
    fi
    
    # Check if we should create backup
    local create_backup=false
    if [[ "$1" == "--backup" ]]; then
        create_backup=true
    fi
    
    # Create backup if requested
    if [ "$create_backup" = true ]; then
        create_backup
    fi
    
    # Check dotfiles directory
    check_dotfiles_dir
    
    # Create directories
    create_directories
    
    # Copy extensions
    copy_extensions
    
    # Set up symlinks
    setup_symlinks
    
    # Create scripts
    create_scripts
    
    # Set up git workflow
    setup_git_workflow
    
    log_success "Quickshell extensions installed successfully"
    
    # Show installation summary
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎨 Installation Complete! 🎨                         ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Your Quickshell extensions are now installed:"
    echo "  • Modules: $CONFIG_DIR/modules/"
    echo "  • Components: $CONFIG_DIR/components/"
    echo "  • Services: $CONFIG_DIR/services/"
    echo "  • Themes: $CONFIG_DIR/themes/"
    echo "  • Config: $CONFIG_DIR/"
    echo ""
    echo "To use your Quickshell extensions:"
    echo "  1. Reload Quickshell: reload-quickshell"
    echo "  2. Use qs commands: qs status, qs fetch, qs merge, etc."
    echo "  3. Check documentation in WORKFLOW.md"
    echo ""
    echo "For more information, see the README.md file in the repository."
}

# Main function
main() {
    # Parse command line arguments
    local dry_run=false
    local backup=false
    local force=false
    
    for arg in "$@"; do
        case "$arg" in
            --help)
                show_help
                exit 0
                ;;
            --backup)
                backup=true
                ;;
            --force)
                force=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            *)
                log_error "Unknown option: $arg"
                show_help
                exit 1
                ;;
        esac
    done
    
    if [ "$dry_run" = true ]; then
        log_info "Dry run mode - showing what will be installed..."
        echo ""
        echo "This script will:"
        echo "  1. Create directories: $CONFIG_DIR/modules/, $CONFIG_DIR/components/, etc."
        echo "  2. Copy Quickshell extensions from $DOTFILES_DIR/.config/quickshell/"
        echo "  3. Set up symlinks for configuration files"
        echo "  4. Create scripts in ~/.local/bin/"
        echo "  5. Set up git workflow"
        echo ""
        echo "To install, run without --dry-run option."
        exit 0
    fi
    
    # Install Quickshell extensions
    install_extensions "$1"
}

# Run main function with all arguments
main "$@"