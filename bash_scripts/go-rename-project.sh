#!/bin/bash

source functions.sh

# Check if the required scripts exist
check_required_scripts() {
    local missing_scripts=0
    
    if ! command -v repo-rename.sh >/dev/null 2>&1; then
        error "Required script 'repo-rename.sh' not found in PATH"
        missing_scripts=1
    fi
    
    if ! command -v go-mod-update.sh >/dev/null 2>&1; then
        error "Required script 'go-mod-update.sh' not found in PATH"
        missing_scripts=1
    fi
    
    return $missing_scripts
}

# Main function to rename a Go project
rename_go_project() {
    local old_name=$1
    local new_name=$2
    local force_rename=${3:-false}  # Default to non-force rename

    # Validate required arguments
    if [ -z "$old_name" ] || [ -z "$new_name" ]; then
        error "Usage: rename_go_project <old-name> <new-name> [force]"
        return 1
    fi
    
    # Check for required scripts
    check_required_scripts || return $?
    
    # Step 1: First check if it's a Go project by looking for go.mod
    if [ ! -f "go.mod" ]; then
        warning "No go.mod file found. This doesn't appear to be a Go project."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warning "Operation cancelled by user"
            return 1
        fi
    fi
    
    # Step 2: Rename the repository
    success "Step 1/2: Renaming repository from '$old_name' to '$new_name'..."
    if ! repo-rename.sh "$old_name" "$new_name" "$force_rename"; then
        error "Repository rename failed"
        return 1
    fi
    
    # Step 3: Update Go module references if go.mod exists
    if [ -f "go.mod" ]; then
        success "Step 2/2: Updating Go module references..."
        if ! go-mod-update.sh "$old_name" "$new_name"; then
            error "Module update failed"
            warning "Repository was renamed but module references may not be fully updated"
            return 1
        fi
    else
        success "Skipping module update as this is not a Go project"
    fi
    
    success "Go project '$old_name' has been successfully renamed to '$new_name'"
    
    # Additional information
    gitHubUser=$(git config --get user.name)
    success "New repository URL: https://github.com/$gitHubUser/$new_name"
   
    # ...existing code...
    
    # Make sure we're displaying the correct, updated module name by reading it after updates
    if [ -f "go.mod" ]; then
        # Force a read of the updated file
        sync
        sleep 1
        module_name=$(grep "^module" go.mod | cut -d ' ' -f 2)
        success "New module name: $module_name"
    fi
    
    # ...existing code...

    if [ -f "go.mod" ]; then
        module_name=$(grep "^module" go.mod | cut -d ' ' -f 2)
        success "New module name: $module_name"
    fi
    
    return 0
}

# Execute directly if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        error "Usage: $0 <old-name> <new-name> [force]"
        exit 1
    fi

    rename_go_project "$1" "$2" "$3"
    exit_code=$?
    successMessages
    exit $exit_code
fi