#!/bin/bash

# script para chequear version git tag local con la remota
source functions.sh

# Verificar si hay cambios pendientes
if [ -n "$(git status --porcelain)" ]; then
   warning "Hay cambios pendientes, realizando commit..."
   
   bash pu.sh
fi


# Obtener la versión del tag local
local_version=$(git describe --tags --abbrev=0)

success "local_version: $local_version"

# Obtener la versión del tag remoto
remote_version=$(git ls-remote --tags origin | awk '{print $2}' | cut -d '/' -f 3 | sort -V | tail -n 1)


success "remote_version: $remote_version"

# Comparar las versiones
if [ "$local_version" != "$remote_version" ]; then

 warning "Las versiones son diferentes. Es necesario push."
    # bash pu.sh 
else

 success "Las versiones son iguales. No es necesario realizar ninguna acción."

fi


successMessages

exit 0