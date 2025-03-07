#!/bin/bash

# actualizar paquetes
go get -u -t ./...

# Ejecutar el comando "go mod tidy" para actualizar los módulos Go.
go mod tidy