#!/bin/bash

# Verificar si se proporciona el parámetro
if [ $# -ne 1 ]; then
  echo "Uso: $0 <nombre_archivo>"
  exit 1
fi

# Asignar nombre del archivo
nombre_archivo=$1

# Eliminar el archivo localmente
rm "$nombre_archivo"

# Realizar el seguimiento de la eliminación
git rm "$nombre_archivo"

# Confirmar los cambios
git commit -m "Eliminar archivo $nombre_archivo"

# Imprimir mensaje de éxito
echo "Archivo $nombre_archivo eliminado con éxito y cambios confirmados en Git."