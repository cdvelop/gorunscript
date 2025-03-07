#!/bin/bash
echo "Ingrese el nombre de la etiqueta antigua: "
read old_tag
echo "Ingrese el nombre de la nueva etiqueta: "
read new_tag

git fetch --all
git tag "$new_tag" "$old_tag"
git tag -d "$old_tag"
git push origin :refs/tags/"$old_tag"
git push --tags