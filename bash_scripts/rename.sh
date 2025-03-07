#!/bin/bash

# Verificar si se proporcionan los dos parámetros
if [ $# -ne 2 ]; then
  echo "Uso: $0 <nombre_actual> <nuevo_nombre>"
  exit 1
fi

# Asignar nombres a los parámetros
nombre_actual=$1
nuevo_nombre=$2

# Renombrar el archivo localmente
mv "$nombre_actual" "$nuevo_nombre"

# Realizar el seguimiento del nuevo nombre
git add "$nuevo_nombre"

# Confirmar los cambios
git commit -m "Renombrar archivo de $nombre_actual a $nuevo_nombre"

# Imprimir mensaje de éxito
echo "Archivo renombrado con éxito a $nuevo_nombre y cambios confirmados en Git."
