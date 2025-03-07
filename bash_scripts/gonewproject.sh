#!/bin/bash
source functions.sh

init_project() {
    local repo_name=$1
    local description=$2
    local visibility=${3:-private}  # Default to private if not specified

    # Validate required arguments
    if [ -z "$repo_name" ] || [ -z "$description" ]; then
        error "Usage: init_project <repo-name> <description> [visibility]"
        return 1
    fi

    # create repository remote 
    if ! repo-remote-create.sh "$repo_name" "$description" "$visibility"; then
        error "Failed to create remote repository"
        return 1
    fi

    # Change to the new repository directory
    cd "$repo_name" || return 1

    # Setup basic go project structure
    if ! go-mod-init.sh; then
        error "Failed to initialize go project"
        return 1
    fi

    # Setup repo-existing-setup
    if ! repo-existing-setup.sh; then
        error "Failed to setup existing repo"
        return 1
    fi

    return 0
}

# Execute if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        error "Usage: $0 <repo-name> <description> [visibility]"
        exit 1
    fi

    init_project "$1" "$2" "$3"
    exit_code=$?
    successMessages
    exit $exit_code
fi