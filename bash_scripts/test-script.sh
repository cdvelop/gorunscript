#!/bin/bash
# Script de prueba para gorunscript

# Importar archivo de funciones comunes
source functions.sh

# Procesar los argumentos
message=""
success "Script ejecutado con éxito"
addOKmessage "Número de argumentos: $#"
addOKmessage "Argumentos recibidos: $@"

# Si recibe un argumento "error", devuelve código de error
if [[ "$1" == "error" ]]; then
  error "Error solicitado!" "Se recibió el argumento 'error'"
  addERRORmessage "Se solicitó finalizar con error"
  successMessages
  exit 1
fi

# Usar la función execute para simular una ejecución
execute "echo 'Esto es una prueba de execute'" \
        "No se pudo ejecutar el comando" \
        "Ejecución exitosa del comando"

# Imprimir mensajes acumulados
successMessages
exit 0