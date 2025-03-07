#!/bin/bash

source functions.sh

backup() {
  case "$OSTYPE" in
    msys*|mingw*)
      warning "backup FreeFileSync iniciado...."
      (execute '"/c/Program Files/FreeFileSync/FreeFileSync.exe" "/c/Users/$(whoami)/SyncWin/SyncSettings.ffs_batch"' &) >/dev/null 2>&1
      # Al agregar & al final del comando, se ejecutará en segundo plano y liberará el terminal.
      ;;
    *)
      error "Este sistema operativo '$OSTYPE' no es compatible con la función de respaldo."
      ;;
  esac
}

backup