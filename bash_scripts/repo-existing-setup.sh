#!/bin/bash

source git-utils.sh

setup_existing_project() {
    local current_folder=$(basename "$(pwd)")
    
    # Verificar si ya existe el repositorio git
    if [ ! -d ".git" ]; then
        error "Not a git repository. Please initialize git first."
        return 1
    fi

    create_changes_file || return $?
    create_git_tag || return $?

    return 0
}

# Execute directly if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_existing_project
    exit_code=$?
    successMessages
    exit $exit_code
fi