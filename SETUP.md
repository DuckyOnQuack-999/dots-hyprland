# 🎨 Quickshell Extended - Complete Setup Guide

This document provides a comprehensive setup guide for the Quickshell Extended project, including all the necessary steps to get your Quickshell extensions up and running.

## 📋 Quick Setup (5 Minutes)

### 1. Clone the Repository
```bash
cd /home/duckyonquack999/GitHub-Repositories
git clone https://github.com/end-4/dots-hyprland.git dots-hyprland
cd dots-hyprland
```

### 2. Set Up Git Workflow
```bash
# Set up the git workflow for managing upstream updates
./update-workflow.sh help
```

### 3. Install Quickshell Extensions
```bash
# Install with backup of existing configuration
./install-quickshell-extended.sh --backup

# Or force install (overwrite existing files)
./install-quickshell-extended.sh --force
```

### 4. Reload Quickshell
```bash
# Reload Quickshell to apply the extensions
reload-quickshell

# Or use the quick command
qs status
```

## 🔧 Detailed Setup Instructions

### 1. Prerequisites

#### System Requirements
- Linux distribution (Arch Linux, Ubuntu, etc.)
- Quickshell installed
- Hyprland or another Wayland compositor
- Git configured with your GitHub credentials

#### Install Quickshell
On Arch Linux:
```bash
sudo pacman -S quickshell
```

On other systems, follow the official installation guide from the Quickshell documentation.

### 2. Repository Setup

#### Clone the Repository
```bash
cd /home/duckyonquack999/GitHub-Repositories

# Clone the end-4/dots-hyprland repository
git clone https://github.com/end-4/dots-hyprland.git dots-hyprland

# Navigate to the repository
cd dots-hyprland
```

#### Set Up Git Remote
```bash
# Rename the default remote to upstream
git remote rename origin upstream

# Add your fork as origin (if you have one)
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/dots-hyprland.git
```

#### Create and Switch to the Quickshell Extended Branch
```bash
# Create the quickshell-extended branch
git checkout -b quickshell-extended
```

### 3. Install Quickshell Extensions

#### Option A: Standard Installation
```bash
# Navigate to the repository
cd /home/duckyonquack999/GitHub-Repositories/dots-hyprland

# Install Quickshell extensions
./install-quickshell-extended.sh
```

#### Option B: Installation with Backup
```bash
# Create a backup of existing configuration before installing
./install-quickshell-extended.sh --backup
```

#### Option C: Force Installation
```bash
# Force install (overwrite existing files)
./install-quickshell-extended.sh --force
```

#### Option D: Dry Run
```bash
# Show what will be installed without making changes
./install-quickshell-extended.sh --dry-run
```

### 4. Set Up Shell Functions

#### Add Quick Commands to Your Shell
```bash
# Add the quick commands to your shell configuration

# For bash users
if ! grep -q "qs-workflow.sh" ~/.bashrc; then
    echo "# Quickshell workflow" >> ~/.bashrc
    echo "source /home/duckyonquack999/GitHub-Repositories/dots-hyprland/qs-workflow.sh" >> ~/.bashrc
fi

# For zsh users
if ! grep -q "qs-workflow.sh" ~/.zshrc; then
    echo "# Quickshell workflow" >> ~/.zshrc
    echo "source /home/duckyonquack999/GitHub-Repositories/dots-hyprland/qs-workflow.sh" >> ~/.zshrc
fi

# Reload your shell configuration
source ~/.bashrc
# or
source ~/.zshrc
```

### 5. Test the Installation

#### Test the Quick Commands
```bash
# Test the quick commands
qs status
qs fetch
qs help
```

#### Test the Git Workflow
```bash
# Test the git workflow
./update-workflow.sh help
./update-workflow.sh status
```

#### Reload Quickshell
```bash
# Reload Quickshell to apply the extensions
reload-quickshell

# Or use the quick command
qs status
```

## 🔧 Troubleshooting

### Common Issues

#### Issue: "Dotfiles directory not found"

If the installation script complains about the dotfiles directory not being found:

1. Check if the `dots` directory exists:
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

#### Issue: "Permission denied"

If you encounter permission issues:

1. Ensure you have the necessary permissions:
   ```bash
   chmod +x /home/duckyonquack999/GitHub-Repositories/dots-hyprland/install-quickshell-extended.sh
   ```

2. If you need to install system-wide, use `sudo`:
   ```bash
   sudo ./install-quickshell-extended.sh
   ```

#### Issue: "Quickshell not found"

If the `reload-quickshell` script cannot find Quickshell:

1. Ensure Quickshell is installed and in your PATH:
   ```bash
   which quickshell
   ```

2. If Quickshell is not installed, install it from the official repository.

### Advanced Troubleshooting

#### Issue: "Merge conflict detected"

If you encounter merge conflicts when updating from upstream:

1. Check conflicted files:
   ```bash
   git status
   ```

2. Use a merge tool:
   ```bash
   git mergetool
   ```

3. Or manually edit files, then:
   ```bash
   git add <resolved-files>
   git commit
   ```

#### Issue: "Rate limited"

If you encounter rate limiting when fetching from upstream:

1. Wait a few minutes and try again
2. Use the `--dry-run` option to avoid unnecessary requests
3. Consider increasing the rate limit in the `update-workflow.sh` script

## 📚 Additional Resources

### Documentation
- [Quickshell Documentation](https://quickshell.org/docs/) - Official Quickshell documentation
- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) - Upstream repository
- [illogical-impulse Wiki](https://end-4.github.io/dots-hyprland-wiki/) - Official documentation

### Community
- [Quickshell Discord](https://discord.gg/quickshell) - Community support
- [GitHub Issues](https://github.com/end-4/dots-hyprland/issues) - Report issues and request features

### Learning Resources
- [Git Branching Strategies](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows) - Git branching strategies
- [Quickshell Tutorials](https://quickshell.org/docs/tutorials/) - Quickshell tutorials

## 🎉 You're Ready!

Your Quickshell Extended installation is now complete! 🎨

### Next Steps:

1. **Explore Your Extensions**:
   - Check what extensions are available in `~/.config/quickshell/`
   - Customize your Quickshell configuration
   - Add new modules or components

2. **Learn More**:
   - Read the documentation in this repository
   - Explore the Quickshell documentation
   - Join the Quickshell community

3. **Share Your Work**:
   - Fork the repository on GitHub
   - Create pull requests with your improvements
   - Share your customizations with the community

### Quick Reference Commands:

```bash
# Quick commands
qs status          # Show current status
qs fetch           # Fetch upstream changes
qs changes         # Show what's new in upstream
qs merge           # Merge upstream changes
qs rebase          # Rebase onto upstream
qs push            # Push to origin (requires fork)
qs backup          # Create backup branch
qs help            # Show help

# Git workflow commands
./update-workflow.sh status
./update-workflow.sh fetch
./update-workflow.sh show-changes
./update-workflow.sh merge
./update-workflow.sh rebase
./update-workflow.sh push
./update-workflow.sh backup
```

Enjoy your Quickshell extensions! 🚀

---

**Need Help?**
- Check the documentation in this repository
- Visit the Quickshell Discord community
- Report issues on GitHub

**Contribute:**
- Fork the repository
- Create pull requests
- Write documentation
- Help others

Happy Quickshell hacking! 🎨✨