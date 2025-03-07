#!/bin/bash

source git-utils.sh

setup_new_project() {
    local current_folder=$(basename "$(pwd)")

    init_base_files "$current_folder" || return $?
    init_new_repo "$current_folder" "$currentGitHostUserPath" || return $?
    create_initial_commit || return $?
    setup_git_remote "$current_folder" "$currentGitHostUserPath" || return $?
    push_to_remote || return $?
    create_git_tag || return $?

    return 0
}

# Execute directly if script is not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_new_project
    exit_code=$?
    successMessages
    exit $exit_code
fi