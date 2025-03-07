#!/bin/bash

source functions.sh

# Obtener el nombre de usuario
username=$(whoami)
# Directorio de paquetes de Go
go_pkgs="/c/Users/$username/Packages/go"


# Función para obtener la última versión de un paquete desde el directorio de paquetes de Go
getLatestVersion() {
    local package_name=$1
    local package_dir="$go_pkgs/$package_name"
    local latest_tag=""

    if [ -d "$package_dir" ]; then
        cd "$package_dir"
        latest_tag=$(git describe --tags --abbrev=0)
    fi

    echo "$latest_tag"
}

# Recorrer el archivo go.mod y comparar las versiones de los paquetes
while IFS= read -r line; do

   if [[ $line =~ (require[[:space:]]+)?($currentGitHostUserPath/.+)[[:space:]]+([^[:space:]]+) ]]; then
    package_name=$(gawk -v repository="$currentGitHostUserPath" 'match($0, repository"/([^[:space:]]+)", arr) {print arr[1]}' <<< "$line")
    current_tag=$(gawk -v repository="$currentGitHostUserPath" 'match($0, repository"/([^[:space:]]+) v?([0-9]+\\.[0-9]+\\.[0-9]+)", arr) {print arr[2]}' <<< "$line")

        # package_name current_tag no están vacíos.
        if [[ -n "$package_name" && -n "$current_tag" ]]; then
            # success "paquete=> [$package_name] versión actual: [$current_tag]"

            # Obtener la última versión del paquete desde el directorio de paquetes de Go
            latest_tag=$(getLatestVersion "$package_name")
            # success " ultima versión: [$latest_tag]"

            if [ "$latest_tag" != "$current_tag" ]; then
                # "El paquete tiene una versión diferente hay que actualizar"
                bash goget.sh $package_name $latest_tag
 
            fi
        fi
    fi
done < "go.mod"

successMessages
