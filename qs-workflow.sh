#!/bin/bash
# qs-workflow.sh - Quick shell function for Quickshell Extended workflow
# 
# Add this to your ~/.bashrc or ~/.zshrc:
# source /home/duckyonquack999/GitHub-Repositories/dots-hyprland/qs-workflow.sh
#
# Then use: qs <command>

REPO_DIR="/home/duckyonquack999/GitHub-Repositories/dots-hyprland"
WORKFLOW_SCRIPT="$REPO_DIR/update-workflow.sh"

qs() {
    local cmd="${1:-help}"
    shift || true
    
    case "$cmd" in
        s|status)
            "$WORKFLOW_SCRIPT" status
            ;;
        f|fetch)
            "$WORKFLOW_SCRIPT" fetch
            ;;
        c|changes|show-changes)
            "$WORKFLOW_SCRIPT" show-changes
            ;;
        m|merge)
            "$WORKFLOW_SCRIPT" merge
            ;;
        r|rebase)
            "$WORKFLOW_SCRIPT" rebase
            ;;
        p|push)
            "$WORKFLOW_SCRIPT" push
            ;;
        b|backup)
            "$WORKFLOW_SCRIPT" backup
            ;;
        h|help|*)
            "$WORKFLOW_SCRIPT" help
            ;;
    esac
}

# Auto-completion for bash
if [ -n "$BASH_VERSION" ]; then
    _qs_complete() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local commands="status fetch changes merge rebase push backup help"
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    }
    complete -F _qs_complete qs
fi

# Auto-completion for zsh
if [ -n "$ZSH_VERSION" ]; then
    compdef _qs_complete qs
    _qs_complete() {
        local commands=(
            'status:Show repository status'
            'fetch:Fetch upstream changes'
            'changes:Show upstream changes'
            'merge:Merge upstream changes'
            'rebase:Rebase onto upstream'
            'push:Push to origin'
            'backup:Create backup branch'
            'help:Show help'
        )
        _describe 'qs' commands
    }
fi

echo "🎨 Quickshell Extended workflow loaded! Use 'qs <command>'"
echo "Commands: status, fetch, changes, merge, rebase, push, backup, help"