package gorunscript

import (
	"os"
	"path/filepath"
)

// getScriptNames obtiene los nombres de los scripts .sh en un directorio
func GetScriptNames(dir string) ([]string, error) {
	files, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	var scripts []string
	for _, f := range files {
		if filepath.Ext(f.Name()) == ".sh" {
			scripts = append(scripts, f.Name())
		}
	}

	return scripts, nil
}
