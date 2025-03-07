#!/bin/bash

# Obtén la última etiqueta
latest_tag=$(git describe --abbrev=0 --tags)

# Extrae el número de la etiqueta
last_number=$(echo "$latest_tag" | grep -oE '[0-9]+$')

# Incrementa el número en uno
next_number=$((last_number + 1))

# Construye la nueva etiqueta
new_tag=$(echo "$latest_tag" | sed "s/$last_number$/$next_number/")

echo "La última etiqueta es: $latest_tag"
echo "La siguiente etiqueta será: $new_tag"