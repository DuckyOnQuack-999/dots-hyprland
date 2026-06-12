# 🎨 Quickshell Extended - Installation Guide

This document explains how to install and set up Quickshell extensions for end-4's dots-hyprland repository.

## 📋 Overview

Quickshell Extended is a collection of Quickshell modules, components, and services that extend the functionality of end-4's dots-hyprland configuration.

## 🚀 Quick Start

### Prerequisites

- Quickshell installed on your system
- Hyprland or another Wayland compositor
- Git configured with your GitHub credentials (for pushing changes)

### Installation Steps

1. **Clone the repository** (if not already done):
   ```bash
   cd /home/duckyonquack999/GitHub-Repositories
   git clone https://github.com/end-4/dots-hyprland.git
   cd dots-hyprland
   ```

2. **Set up the git workflow** (for managing upstream updates):
   ```bash
   cd dots-hyprland
   ./update-workflow.sh help
   ```

3. **Install Quickshell extensions**:
   ```bash
   ./install-quickshell-extended.sh
   ```

4. **Reload Quickshell**:
   ```bash
   reload-quickshell
   ```

## 📁 Installation Options

### Standard Installation

```bash
# Install with backup of existing configuration
./install-quickshell-extended.sh --backup

# Force install (overwrite existing files)
./install-quickshell-extended.sh --force

# Dry run (show what will be installed)
./install-quickshell-extended.sh --dry-run
```

### Environment Variables

You can set the following environment variables before running the installation:

- `DOTFILES_DIR`: Directory containing dotfiles (default: `./dots`)
- `CONFIG_DIR`: Quickshell config directory (default: `~/.config/quickshell`)
- `BACKUP_DIR`: Backup directory (default: `~/.backup/dots-hyprland`)

Example:
```bash
export DOTFILES_DIR="/path/to/dots"
export CONFIG_DIR="/home/user/.config/quickshell"
export BACKUP_DIR="/home/user/.backup/dots-hyprland"

./install-quickshell-extended.sh
```

## 🛠️ Installation Details

### What Gets Installed

The installation script will:

1. **Create necessary directories**:
   - `~/.config/quickshell/modules/`
   - `~/.config/quickshell/components/`
   - `~/.config/quickshell/services/`
   - `~/.config/quickshell/themes/`
   - `~/.local/bin/`

2. **Copy Quickshell extensions**:
   - Custom modules from `dots/.config/quickshell/modules/`
   - Custom components from `dots/.config/quickshell/components/`
   - Custom services from `dots/.config/quickshell/services/`
   - Custom themes from `dots/.config/quickshell/themes/`
   - `shell.qml` configuration file

3. **Set up symlinks** for configuration files:
   - `config.json`
   - `settings.json`

4. **Create scripts**:
   - `reload-quickshell`: Script to reload Quickshell configuration
   - Add `~/.local/bin` to PATH

5. **Set up git workflow**:
   - Configure `update-workflow.sh` for managing upstream updates
   - Configure `qs-workflow.sh` for quick commands

### Directory Structure

After installation, your Quickshell configuration will be organized as follows:

```
~/.config/quickshell/
├── modules/
│   ├── sidebar/
│   ├── dashboard/
│   └── ...
├── components/
│   ├── button/
│   ├── panel/
│   └── ...
├── services/
│   ├── weather/
│   ├── system/
│   └── ...
├── themes/
│   ├── default/
│   ├── dark/
│   └── ...
├── shell.qml
├── config.json
├── settings.json
└── ...
```

## 🔄 Git Workflow

The installation script also sets up a comprehensive git workflow for managing upstream updates:

### Quick Commands

Use the `qs` function (source `qs-workflow.sh`) for quick commands:

```bash
# Show current status
qs status

# Fetch upstream changes
qs fetch

# Show what's new in upstream
qs changes

# Merge upstream changes
qs merge

# Rebase onto upstream (cleaner history)
qs rebase

# Create backup
qs backup

# Show help
qs help
```

### Workflow Commands

For more detailed control, use the `update-workflow.sh` script:

```bash
# Show help
./update-workflow.sh help

# Show current status
./update-workflow

# Fetch upstream changes
./update-workflow.sh fetch

# Show what's new in upstream
./update-workflow.sh show-changes

# Merge upstream changes
./update-workflow.sh merge

# Rebase onto upstream
./update-workflow.sh rebase

# Push to origin (requires fork)
./update-workflow.sh push

# Create backup
./update-workflow.sh backup
```

## 🔄 Updating from Upstream

To keep your Quickshell extensions up to date with upstream changes:

1. **Fetch upstream changes**:
   ```bash
   ./update-workflow.sh fetch
   ```

2. **See what's new**:
   ```bash
   ./update-workflow.sh show-changes
   ```

3. **Merge or rebase**:
   ```bash
   # For beginners (preserves history)
   ./update-workflow.sh merge

   # For cleaner history
   ./update-workflow.sh rebase
   ```

4. **Resolve conflicts** if they occur:
   ```bash
   # Check conflicted files
   git status

   # Edit conflicting files
   git add <resolved-files>
   git commit
   ```

## 🛠️ Troubleshooting

### Common Issues

#### "Dotfiles directory not found"

If the installation script complains about the dotfiles directory not being found:

1. Check if the `dots` directory exists in the repository:
   ```bash
   ls -la /home/duckyonquack999/GitHub-Repositories/dots-hyprland/
   ```

2. If the `dots` directory doesn't exist, create it:
   ```bash
   mkdir -p /home/duckyonquack999/GitHub-Repositories/dots-hyprland/dots
   ```

3. Copy the Quickshell extensions from the repository to the `dots` directory:
   ```bash
   cp -r /home/duckyonquack999/GitHub-Repositories/dots-hyprland/.config/quickshell/ /home/duckyonquack999/GitHub-Repositories/dots-hyprland/dots/
   ```

#### "Permission denied"

If you encounter permission issues:

1. Ensure you have the necessary permissions:
   ```bash
   chmod +x /home/duckyonquack999/GitHub-Repositories/dots-hyprland/install-quickshell-extended.sh
   ```

2. If you need to install system-wide, use `sudo`:
   ```bash
   sudo ./install-quickshell-extended.sh
   ```

#### "Quickshell not found in PATH"

If the `reload-quickshell` script cannot find Quickshell:

1. Ensure Quickshell is installed and in your PATH:
   ```bash
   which quickshell
   ```

2. If Quickshell is not installed, install it from the official repository.

## 📚 Additional Resources

- [Quickshell Documentation](https://quickshell.org/docs/) - Official Quickshell documentation
- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) - Upstream repository
- [illogical-impulse Wiki](https://end-4.github.io/dots-hyprland-wiki/) - Official documentation
- [Git Branching Strategies](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows) - Git branching strategies

## 🎉 You're Ready!

Your Quickshell extensions are now installed and ready to use! 🎨

To get started:

1. **Reload Quickshell**:
   ```bash
   reload-quickshell
   ```

2. **Use quick commands**:
   ```bash
   qs status
   qs fetch
   qs merge
   ```

3. **Check documentation**:
   - `WORKFLOW.md` - Detailed workflow documentation
   - `INSTALL.md` - Installation instructions
   - `README.md` - Repository overview

Enjoy your Quickshell extensions! 🚀