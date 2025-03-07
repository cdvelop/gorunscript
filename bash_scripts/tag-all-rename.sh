#!/bin/bash

# Este script permite renombrar múltiples tags de git de forma masiva
# Recibe como parámetro un archivo que contiene en cada línea:
# <nombre_tag_antiguo> <nombre_tag_nuevo>
# 
# El script realiza las siguientes operaciones para cada línea:
# 1. Crea el nuevo tag apuntando al commit del tag antiguo
# 2. Elimina el tag antiguo localmente
# 3. Elimina el tag antiguo del repositorio remoto
# 4. Sube todos los tags al repositorio remoto

filename="$1"
git fetch --all
while read -r old_tag new_tag; do
    git tag "$new_tag" "$old_tag"
    git tag -d "$old_tag"
    git push origin :refs/tags/"$old_tag"
    git push --tags
done < "$filename"