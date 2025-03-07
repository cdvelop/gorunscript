#!/bin/bash

source functions.sh

check_rename_permissions() {
    # First check if gh CLI is authenticated at all
    if ! gh auth status >/dev/null 2>&1; then
        warning "GitHub CLI not authenticated. Please run: gh auth login"
        return 1
    fi
    
    return 0
}

rename_repository() {
    local old_name=$1
    local new_name=$2
    local force_rename=${3:-false}  # Default to non-force rename

    # Validate required arguments
    if [ -z "$old_name" ] || [ -z "$new_name" ]; then
        error "Usage: rename_repository <old-name> <new-name> [force]"
        return 1
    fi

    # Check permissions first
    check_rename_permissions || return $?

    # Get GitHub username from local git config
    gitHubUser=$(git config --get user.name)
    if [ -z "$gitHubUser" ]; then
        error "Unable to get GitHub username from git config"
        return 1
    fi
    
    # Define directory variables BEFORE using them in conditions
   # Get directory structure
    local current_dir=$(basename "$PWD")
    local parent_dir=$(basename "$(dirname "$PWD")")
    local grandparent_dir=$(basename "$(dirname "$(dirname "$PWD")")")    # ...existing code...
    
    # Get directory structure
    local current_dir=$(basename "$PWD")
    local parent_dir=$(basename "$(dirname "$PWD")")
    local grandparent_dir=$(basename "$(dirname "$(dirname "$PWD")")")
        
    # Update local folder renaming to support both Packages/name and Packages/Internal/name structures
    if [ "$current_dir" = "$old_name" ]; then
        if [ "$parent_dir" = "Packages" ] || [ "$parent_dir" = "Internal" -a "$grandparent_dir" = "Packages" ]; then
            # We're either in Packages/oldName or Packages/Internal/oldName, rename the folder
            cd ..
            execute "mv $old_name $new_name" \
                "Failed to rename local directory" \
                "Local directory renamed from $old_name to $new_name" || return $?
            cd "$new_name"
            
            # Update Git remotes
            execute "git remote set-url origin https://github.com/$gitHubUser/$new_name.git" \
                "Failed to update Git remote URL" \
                "Git remote URL updated successfully" || return $?
            
            # If it's a Go module, update module name
            if [ -f "go.mod" ]; then
                success "Go module detected. Updating module name..."
                if command -v repo-module-update.sh >/dev/null 2>&1; then
                    repo-module-update.sh "$old_name" "$new_name"
                else
                    warning "repo-module-update.sh script not found. Module name not updated."
                fi
            fi
        else
            success "Not in a standard Packages directory structure. Local folder not renamed."
        fi
    else
        success "Current directory name doesn't match old name. Local folder not renamed."
    fi

    # Confirm rename unless force flag is set
    if [ "$force_rename" != "true" ]; then
        read -p "Are you sure you want to rename repository '$old_name' to '$new_name'? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warning "Operation cancelled by user"
            return 1
        fi
    fi

    # Rename repository using GitHub CLI
    if [ "$current_dir" = "$old_name" ]; then
        # If we're in the repository directory, use simpler syntax
        execute "gh repo rename $new_name --yes" \
            "Failed to rename repository" \
            "Repository renamed from $old_name to $new_name successfully" || return $?
    else
        # If we're not in the repository directory, use the API directly
        execute "gh api -X PATCH repos/$gitHubUser/$old_name -f name=$new_name" \
            "Failed to rename repository" \
            "Repository renamed from $old_name to $new_name successfully" || return $?
    fi
    
    if [ "$current_dir" = "$old_name" ] && [ "$parent_dir" = "Packages" ]; then
        # We're in Packages/oldName, rename the folder
        cd ..
        execute "mv $old_name $new_name" \
            "Failed to rename local directory" \
            "Local directory renamed from $old_name to $new_name" || return $?
        cd "$new_name"
        
        # Update Git remotes
        execute "git remote set-url origin https://github.com/$gitHubUser/$new_name.git" \
            "Failed to update Git remote URL" \
            "Git remote URL updated successfully" || return $?
            
        # If it's a Go module, update module name
        if [ -f "go.mod" ]; then
            success "Go module detected. Updating module name..."
            if command -v repo-module-update.sh >/dev/null 2>&1; then
                repo-module-update.sh "$old_name" "$new_name"
            else
                warning "repo-module-update.sh script not found. Module name not updated."
            fi
        fi
    else
        success "Not in Packages/$old_name directory. Local folder not renamed."
    fi

    return 0
}

# Execute directly if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        error "Usage: $0 <old-name> <new-name> [force]"
        exit 1
    fi

    rename_repository "$1" "$2" "$3"
    exit_code=$?
    successMessages
    exit $exit_code
fi