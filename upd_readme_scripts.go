package gorunscript

import (
	"crypto/md5"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
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

// getScriptDescriptions obtiene las descripciones de los scripts
func GetScriptDescriptions(dir string) (map[string]string, error) {
	scripts, err := GetScriptNames(dir)
	if err != nil {
		return nil, err
	}

	descriptions := make(map[string]string)
	descPattern := regexp.MustCompile(`(?i)^#\s*desc(ription)?:\s*(.+)$`)

	for _, script := range scripts {
		content, err := os.ReadFile(filepath.Join(dir, script))
		if err != nil {
			return nil, err
		}

		if len(content) == 0 {
			descriptions[script] = "Empty script file"
			continue
		}

		lines := strings.Split(string(content), "\n")
		found := false
		endLine := min(10, len(lines))

		// Buscar en primeras líneas (hasta 10)
		for _, line := range lines[:endLine] {
			if matches := descPattern.FindStringSubmatch(line); matches != nil {
				descriptions[script] = strings.TrimSpace(matches[2])
				found = true
				break
			}
		}

		if !found {
			descriptions[script] = generateAutoDescription(script, strings.Join(lines, "\n"))
		}
	}

	return descriptions, nil
}

// min devuelve el menor de dos enteros
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func generateAutoDescription(name, content string) string {
	// Lógica para generar descripción basada en nombre y contenido
	keywords := map[string]string{
		"git":    "Git operations",
		"repo":   "Repository management",
		"setup":  "System setup/config",
		"update": "Dependency updates",
		"go":     "Go language utilities",
	}

	var desc []string
	for k, v := range keywords {
		if strings.Contains(strings.ToLower(name), k) {
			desc = append(desc, v)
		}
	}

	if len(desc) == 0 {
		return "Shell script utility"
	}
	return strings.Join(desc, ", ")
}

func GenerateReadmeSection(descriptions map[string]string) string {
	var sb strings.Builder
	sb.WriteString("## Available Scripts\n\n")
	sb.WriteString("| Script Name | Description |\n")
	sb.WriteString("|-------------|-------------|\n")

	for script, desc := range descriptions {
		sb.WriteString(fmt.Sprintf("| `%s` | %s |\n", script, desc))
	}

	return sb.String()
}

func UpdateReadmeIfNeeded(scriptsSection string, readmePath string) (bool, error) {
	existing, err := os.ReadFile(readmePath)
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return false, err
	}

	// Mejorar expresión regular para manejar espacios y comentarios
	sectionStart := regexp.QuoteMeta("<!-- SCRIPTS_SECTION_START -->")
	sectionEnd := regexp.QuoteMeta("<!-- SCRIPTS_SECTION_END -->")
	pattern := regexp.MustCompile(`(?s)` + sectionStart + `\s*[\S\s]*?\s*` + sectionEnd)

	newSection := fmt.Sprintf("%s\n%s\n%s",
		"<!-- SCRIPTS_SECTION_START -->",
		scriptsSection,
		"<!-- SCRIPTS_SECTION_END -->")

	var newContent string
	currentContent := string(existing)

	if currentContent == "" {
		// Crear nuevo README solo con la sección
		newContent = newSection + "\n"
	} else if pattern.MatchString(currentContent) {
		// Reemplazar sección existente
		newContent = pattern.ReplaceAllString(currentContent, newSection)
	} else {
		// Agregar sección al final del archivo
		newContent = strings.TrimSpace(currentContent) + "\n\n" + newSection
	}

	// Comparar hash MD5 del contenido
	existingHash := md5.Sum(existing)
	newHash := md5.Sum([]byte(newContent))

	if existingHash != newHash {
		return true, os.WriteFile(readmePath, []byte(newContent), 0644)
	}

	return false, nil
}
