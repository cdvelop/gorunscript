#!/bin/bash

pkg_updated=$1

new_tag="v10.0.0"

go_mod_file="go.mod"

# Parte común de la dirección del paquete
pkg_common="github.com/cdvelop"


old_tag=$(gawk -v package="$pkg_updated" -v common="$pkg_common" 'match($0, "^require[[:space:]]+" common "/" package "[[:space:]]+([^[:space:]]+)", tag) {print tag[1]; exit} $1==common "/" package {print $2}' "$go_mod_file")

echo "=> Actualizando paquete: test modulo: $pkg_updated ver anterior: $old_tag nueva: $new_tag"
