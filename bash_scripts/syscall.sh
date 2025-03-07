#!/bin/bash

# source functions.sh

syscall(){
    pkg_name=$1
    #  warning "Error Encontrado en paquete $pkg_name"
    found=0  # Variable para rastrear si se encontró la coincidencia

    for file in $(find . -type f -name "*.go"); do
        # echo "Archivo encontrado: $file de tipo syscall/js en paquete $pkg_name"

        if grep -q "syscall/js" "$file"; then
            found=1
            break
        fi

    done

    # success "paquete $pkg_name de tipo 'syscall/js'."

    return $found
}

# execute "go vet" "go vet en $go_mod_name ha fallado" "go vet $go_mod_name ok" "no exist"
# syscall $? $go_mod_name