#!/bin/bash

username=$(whoami)
go_pkgs="/c/Users/$username/Packages/go"

echo "Ruta go packages: $go_pkgs"

 if [ -d $go_pkgs ]; then

   echo "existe : $go_pkgs"
 
 fi
