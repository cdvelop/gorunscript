#!/bin/bash

# Lee el archivo de texto que contiene las etiquetas a eliminar
while read tag; do
  # Elimina la etiqueta localmente
  git tag -d "$tag"
  # Elimina la etiqueta en el repositorio remoto
  git push origin --delete "$tag"
done < "$1"
