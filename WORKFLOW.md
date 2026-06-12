# 🎨 Quickshell Extended - Git Workflow for end-4's dots-hyprland

This document explains how to manage your local Quickshell extensions while keeping up with upstream updates from end-4's dots-hyprland repository.

## 📋 Overview

You're working with **end-4's dots-hyprland** (illogical-impulse) and want to:
- ✅ Keep your local Quickshell customizations
- ✅ Pull upstream updates without losing your changes
- ✅ Avoid reapplying changes manually after each update

## 🌿 Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Tracks upstream/main (read-only) |
| `quickshell-extended` | Your local Quickshell extensions and customizations |

## 🚀 Quick Start

### 1. Initial Setup (Already Done!)
```bash
cd /home/duckyonquack999/GitHub-Repositories/dots-hyprland
# Repository cloned, upstream remote configured, branch created
```

### 2. Make Your Changes
```bash
# Work on your Quickshell extensions in the 'dots' directory
# Edit files, add new widgets, customize themes, etc.

# Commit your changes
git add .
git commit -m "feat: add awesome Quickshell widget"
```

### 3. When Upstream Updates
```bash
# Option A: Merge (preserves history, easier conflict resolution)
./update-workflow.sh merge

# Option B: Rebase (cleaner history, more complex conflicts)
./update-workflow.sh rebase
```

## 📖 Detailed Workflow

### Daily Development
```bash
# 1. Check status
./update-workflow.sh status

# 2. Make changes to Quickshell configs in dots/
#    - dots/.config/quickshell/...
#    - dots/.config/quickshell/modules/...
#    - dots/.config/quickshell/components/...

# 3. Commit frequently
git add -A
git commit -m "feat: describe your change"
```

### Updating from Upstream
```bash
# 1. See what's new
./update-workflow.sh fetch
./update-workflow.sh show-changes

# 2. Merge or rebase
./update-workflow.sh merge    # Recommended for beginners
# OR
./update-workflow.sh rebase   # For cleaner history

# 3. If conflicts occur:
#    - Run: git status
#    - Edit conflicting files
#    - Run: git add <resolved-files>
#    - Run: git commit (for merge) or git rebase --continue (for rebase)
```

### Backup Before Major Changes
```bash
./update-workflow.sh backup
# Creates a branch like: backup-20241219-143022
```

### Sharing Your Work (Optional)
```bash
# 1. Fork end-4/dots-hyprland on GitHub
# 2. Add your fork as origin
git remote add origin https://github.com/YOUR_USERNAME/dots-hyprland.git

# 3. Push your branch
./update-workflow.sh push
```

## 🎯 Quickshell Extension Points

Your customizations should go in these directories:

```
dots/
├── .config/quickshell/
│   ├── modules/           # Custom modules (sidebar, widgets, etc.)
│   ├── components/        # Reusable UI components
│   ├── services/          # Custom services (API integrations)
│   ├── themes/            # Custom themes
│   └── shell.qml          # Main entry point (modify carefully)
```

## 🔧 Advanced Tips

### Cherry-picking Specific Upstream Changes
```bash
# If you only want specific commits from upstream
git fetch upstream
git log upstream/main --oneline -20
git cherry-pick <commit-hash>
```

### Keeping Config Files Separate
For machine-specific configs, use the `dots-extra` directory or create a separate config overlay.

### Automated Updates (Cron)
```bash
# Add to crontab for daily upstream checks
0 9 * * * cd /home/duckyonquack999/GitHub-Repositories/dots-hyprland && ./update-workflow.sh fetch >/dev/null 2>&1
```

## 🆘 Troubleshooting

### Merge Conflicts
```bash
# Check conflicted files
git status

# Use a merge tool
git mergetool

# Or manually edit files, then:
git add <files>
git commit
```

### Lost Changes?
```bash
# Check reflog for recent commits
git reflog

# Restore from backup branch
git checkout backup-20241219-143022
```

### Upstream Force Push (Rare)
```bash
# If upstream rewrites history (very rare)
git fetch upstream
git reset --hard upstream/main
# Then re-apply your changes from backup
```

## 📚 Resources

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) - Upstream repository
- [illogical-impulse Wiki](https://end-4.github.io/dots-hyprland-wiki/) - Official documentation
- [Quickshell Documentation](https://quickshell.org/docs/) - Widget system docs
- [Git Branching Strategies](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)

## 🎉 You're Ready!

Your Quickshell extensions are now safely managed. Happy customizing! 🎨