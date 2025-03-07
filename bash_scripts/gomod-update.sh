#!/bin/bash

source functions.sh

# Verificar si se proporcionaron dos parámetros
if [ "$#" -ne 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
  error "Se requieren nombre de paquete y versión ej: mipkg v0.0.2"
  exit 1
fi

# paquete a actualizar
pkg_was_updated=$1
# version nueva
pkg_tag_was_update=$2


if [ -d $go_pkgs ]; then
   
    for observed_pkg in "$go_pkgs"/*; do
         
      # Verificar que el paquete no sea el actualizado recientemente
      if [ "$(basename "$observed_pkg")" != "$pkg_was_updated" ]; then

        go_mod_file="$observed_pkg/go.mod"

        if [ -f "$go_mod_file" ]; then
          
          # Obtener el nombre del paquete observado
          observed_pkg_name=$(gawk -v pattern=$currentGitHostUserPath/ 'NR==1 && match($0, pattern "([^/]+)", arr) { print arr[1] }' $go_mod_file)
            
          old_tag=$(gawk -v package="$pkg_was_updated" -v common="$currentGitHostUserPath" 'match($0, "^require[[:space:]]+" common "/" package "[[:space:]]+([^[:space:]]+)", tag) {print tag[1]; exit} $1==common "/" package {print $2}' "$go_mod_file")

            # Verificar si la variable old_tag no está vacía
            if [ -z "$old_tag" ]; then
                continue
            fi

            # Comparar la versión del paquete observado con la nueva versión
            if [ "$old_tag" != "$pkg_tag_was_update" ]; then
              current_dir=$(pwd)
              cd "$observed_pkg"
                
                # actualizamos solo el paquete que cambio
                execute "go get $currentGitHostUserPath/$pkg_was_updated@$pkg_tag_was_update" "no se actualizo paquete $pkg_was_updated en $observed_pkg_name" 
                
                # actualizamos el resto de paquetes go
                execute "go get -u all" "no se pudieron actualizar los paquetes en $observed_pkg_name"      
                
                # actualizamos y limpiamos el archivo go.mod
                execute "go mod tidy" "go mod tidy en $observed_pkg_name ha fallado"

                bash gomod-check.sh
                if [ $? -eq 0 ]; then # Verificar si es 0 subimos los cambios

                    bash pu.sh "update module: $pkg_was_updated"

                    addOKmessage "paquete $pkg_was_updated actualizado en $observed_pkg_name"

                  else

                    addERRORmessage "tests en paquete: $observed_pkg_name después de actualizar: [$pkg_was_updated]"

                fi

              cd "$current_dir"
            fi
        fi
      fi
    done
fi
successMessages
exit 0
