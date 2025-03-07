#!/bin/bash

# Verifica si se proporcionaron los parámetros necesarios
if [ $# -ne 2 ]; then
    echo "Uso: $0 <testName> <fileName> ej: CreateFile create"
    exit 1
fi

# Nombre de la función de prueba
testName=$1

# Nombre del archivo sin extensión
file=$2"_test.go"

# Nombre de la carpeta actual
packageName=$(basename "$(pwd)")

# Plantilla del archivo de prueba de unidad de Go
template=$(cat <<EOF
package ${packageName}_test

import (
	"bytes"
	"reflect"
	"testing"
)

	var testData${testName} = []struct {
		Comment       string
		DataIN        any
		DataExpected  any
		ErrorExpected error
	}{

		{
			Comment:       "prueba",
			DataIN:        []any,
			DataExpected:  map[string]string{"price": "2000"},
			ErrorExpected: nil,
		},
	
	}

func Test${testName}(t *testing.T) {

	message := func(comment string, expected, response any) {
		t.Fatalf("\n❌=> en %v la expectativa es:\n[%v]\n=> pero se obtuvo:\n[%v]\n", comment, expected, response)
	}

	compare := func(comment string, expected, response any) {
		if !reflect.DeepEqual(expected, response) {
			message(comment, expected, response)
		}
	}

	for _, test := range testData${testName} {
		t.Run(("\n" + test.Comment), func(t *testing.T) {
		
			var buf = &bytes.Buffer{}

			response,err := ${packageName}.${testName}(buf,test.DataIN...)
			compare("ErrorExpected", test.ErrorExpected, err)
			if err == "" {
				compare(test.Comment, test.DataExpected, response)
			}
		})
	}
}

func Benchmark${testName}(b *testing.B) {

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		for _, test := range testData${testName} {
			var buf = &bytes.Buffer{}
			${packageName}.${testName}(buf,test.DataIN...)
		}
	}
}
EOF
)

# Crea el archivo en el directorio actual
echo "$template" > "$file"

echo "Archivo $file creado."
