#!/bin/bash

source functions.sh

check_delete_permissions() {
    # First check if gh CLI is authenticated at all
    if ! gh auth status >/dev/null 2>&1; then
        warning "GitHub CLI not authenticated. Please run: gh auth login"
        return 1
    fi
    
    # Check if we have delete_repo scope
    if ! gh auth status 2>&1 | grep -q "delete_repo"; then
        warning "Requesting delete_repo permission..."
        
        # Request delete_repo scope
        if ! gh auth refresh -h github.com -s delete_repo; then
            error "Failed to obtain delete_repo permission"
            return 1
        fi
        
        # Verify we got the permission
        if ! gh auth status 2>&1 | grep -q "delete_repo"; then
            error "Still missing delete_repo permission after refresh"
            return 1
        fi
        
        success "Delete permission granted successfully"
    fi
    return 0
}

delete_repository() {
    local repo_name=$1
    local force_delete=${2:-false}  # Default to non-force delete

    # Validate required arguments
    if [ -z "$repo_name" ]; then
        error "Usage: delete_repository <repo-name> [force]"
        return 1
    fi

    # Check permissions first
    check_delete_permissions || return $?

    # Confirm deletion unless force flag is set
    if [ "$force_delete" != "true" ]; then
        read -p "Are you sure you want to delete repository '$repo_name'? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warning "Operation cancelled by user"
            return 1
        fi
    fi

    # Delete repository using --yes instead of --confirm
    execute "gh repo delete $gitHubUser/$repo_name --yes" \
        "Failed to delete repository" \
        "Repository $repo_name deleted successfully" || return $?

    return 0
}

# Execute directly if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        error "Usage: $0 <repo-name> [force]"
        exit 1
    fi

    delete_repository "$1" "$2"
    exit_code=$?
    successMessages
    exit $exit_code
fi