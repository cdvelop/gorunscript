package gorunsh

import (
	"embed"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
)

//go:embed bash_scripts/*.sh
var bash_scripts embed.FS

// ExtractScripts extracts all embedded scripts to a temporary directory and returns the path
func ExtractScripts() (string, error) {
	tempDir, err := os.MkdirTemp("", "scriptutils-")
	if err != nil {
		return "", fmt.Errorf("failed to create temp dir: %w", err)
	}

	// Walk through all embedded files
	err = fs.WalkDir(bash_scripts, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			return nil
		}

		// Read file content
		content, err := bash_scripts.ReadFile(path)
		if err != nil {
			return fmt.Errorf("failed to read embedded file %s: %w", path, err)
		}

		// Get the base filename
		fileName := filepath.Base(path)
		outputPath := filepath.Join(tempDir, fileName)

		// Write file to temp directory
		if err := os.WriteFile(outputPath, content, 0755); err != nil {
			return fmt.Errorf("failed to write file %s: %w", outputPath, err)
		}

		return nil
	})

	if err != nil {
		os.RemoveAll(tempDir)
		return "", err
	}

	return tempDir, nil
}

// RunScript executes a script with given arguments
func RunScript(scriptPath string, args ...string) (string, error) {
	cmd := exec.Command("bash", append([]string{scriptPath}, args...)...)
	output, err := cmd.CombinedOutput()
	return string(output), err
}
