#!/bin/bash

# Verificar si se proporcionan archivos como argumentos
if [ $# -eq 0 ]; then
  echo "Uso: $0 <archivo1> [archivo2 ...]"
  exit 1
fi

# Procesar cada archivo proporcionado como argumento
for archivo in "$@"; do
  # Paso 1: Dejar de rastrear el archivo localmente
  git rm --cached "$archivo"

  # Paso 2: Actualizar el archivo .gitignore
  #echo "$archivo" >> .gitignore

  # Paso 3: Confirmar los cambios localmente
  git commit -m "Dejar de rastrear el archivo $archivo localmente"

  # Paso 4: Eliminar el archivo del seguimiento remoto (si es necesario)
  git rm --cached "$archivo"

  # Paso 5: Confirmar y empujar los cambios al repositorio remoto
  git commit -m "Dejar de rastrear el archivo $archivo en el seguimiento remoto"
  git push origin "$(git branch --show-current)"

  echo "El archivo $archivo ha dejado de ser rastreado local y remotamente."
done