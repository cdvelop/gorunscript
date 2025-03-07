#!/bin/bash

# Recibe las etiquetas como argumentos separados por espacios
tags="$@"

for tag in $tags; do
  # Elimina la etiqueta localmente
  git tag -d "$tag"
  
  # Elimina la etiqueta en el repositorio remoto
  git push origin --delete "$tag"
done