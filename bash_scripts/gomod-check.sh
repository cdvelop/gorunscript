#!/bin/bash

source functions.sh
source syscall.sh


if [ -f "go.mod" ]; then
  #obtenemos el nombre del modulo go
  go_mod_name=$(gawk -v pattern=$currentGitHostUserPath/ 'NR==1 && match($0, pattern "([^/]+)", arr) { print arr[1] }' go.mod)
  
  # actualizar los paquetes actuales
  execute "go get -u all" "no se pudieron actualizar los paquetes en $go_mod_name" 

  # verificar código
  execute "go mod tidy" "go mod tidy en $go_mod_name ha fallado" "go mod tidy $go_mod_name ok"
  syscall $go_mod_name
  syscall_found=$?


if [ $syscall_found -eq 0 ]; then
  go_vet_dir=""
    # success "directorio $go_mod_name"
    if [ -d "cmd" ]; then
    # success "$go_mod_name contiene carpeta cmd"

    if [ -d "cmd/$go_mod_name" ]; then
        go_vet_dir="./cmd/$go_mod_name"
    else
        go_vet_dir="./cmd"
    fi
    execute "go vet $go_vet_dir" "go vet en $go_mod_name $go_vet_dir ha fallado" "go vet $go_mod_name $go_vet_dir ok"

    if [ -n "$(find . -type f -name "*_test.go")" ]; then
        execute "go test" "Hubo errores en las pruebas en $go_mod_name" "root test $go_mod_name ok"
    fi

    # Buscar carpetas que contengan nombre test y ejecutar tests
    test_folders=$(find -type d -name "*test*")
    for folder in $test_folders; do
        if [ -n "$(find $folder -type f -name "*_test.go")" ]; then
            execute "go test $folder" "Hubo errores en las pruebas carpeta $folder en $go_mod_name" "$go_mod_name carpeta: $folder test ok"
        fi
    done

  fi
fi
  
  # Ejecutar prueba de carrera de datos con go run
  race_output=$(go run -race "$go_mod_name" 2>&1)
  if [[ $race_output == *"WARNING: DATA RACE"* ]]; then
    warning "$race_output"
  fi
  
  successMessages
  exit 0
fi

exit 1
