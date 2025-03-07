#!/bin/bash

source functions.sh

pkg_name=$1

pkg_path=$go_pkgs/$pkg_name
# warning "directorio del paquete a actualizar $pkg_path"

current_dir=$(pwd)

# ir al directorio del paquete a actualizar
cd "$pkg_path"


tag_version=$(git describe --tags --abbrev=0)
# warning "$pkg_name versión tag local: $tag_version"


# volver a la ruta
cd "$current_dir"

execute "go get $currentGitHostUserPath/$1@$tag_version" "al obtener paquete $pkg_name" "$pkg_name actualizado ok"

execute "go mod tidy" "go mod tidy ha fallado" "go mod tidy ok"

successMessages
exit 0