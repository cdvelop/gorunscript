#!/bin/bash

# Obtener la URL remota actual
remote_info=$(git remote -v)

# Imprimir la URL remota actual
echo "URL remota actual:"
echo "$remote_info"

# Verificar si se proporcionó un nuevo origen como argumento
if [ -z "$1" ]; then
  echo "ERROR: No se proporcionó un nuevo origen como argumento."
  echo "ej: change-remote.sh https://github.com/tu-usuario/tu-repositorio.git"
  exit 1
fi

# Obtener el nuevo origen del argumento
new_origin=$1

# Cambiar la URL remota
git remote set-url origin "$new_origin"

# Imprimir la URL remota actualizada
echo "URL remota actualizada:"
git remote -v
