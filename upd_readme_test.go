package gorunscript

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestUpdateReadme(t *testing.T) {
	// Configurar directorio temporal para pruebas
	tmpDir := t.TempDir()

	t.Run("Actualizar sección manteniendo contenido existente", func(t *testing.T) {
		// Crear README de prueba con contenido alrededor de la sección
		testContent := `# Proyecto Ejemplo

<!-- SCRIPTS_SECTION_START -->
Contenido antiguo que debe ser reemplazado
<!-- SCRIPTS_SECTION_END -->

## Otros contenidos
Este texto debe permanecer intacto.`

		testPath := filepath.Join(tmpDir, "README.md")
		err := os.WriteFile(testPath, []byte(testContent), 0644)
		if err != nil {
			t.Fatal(err)
		}

		// Obtener descripciones reales
		descriptions, err := GetScriptDescriptions("bash_scripts")
		if err != nil {
			t.Fatalf("Error obteniendo scripts: %v", err)
		}

		// Generar nueva sección
		newSection := GenerateReadmeSection(descriptions)

		// Ejecutar actualización
		updated, err := UpdateReadmeIfNeeded(newSection, testPath)
		if err != nil {
			t.Fatalf("Error actualizando README: %v", err)
		}

		if !updated {
			t.Error("Debió detectar cambios y actualizar el README")
		}

		// Verificar contenido actualizado
		content, err := os.ReadFile(testPath)
		if err != nil {
			t.Fatal(err)
		}

		// Verificar que se mantuvo el contenido exterior
		if !strings.Contains(string(content), "## Otros contenidos") ||
			!strings.Contains(string(content), "Este texto debe permanecer intacto") {
			t.Error("Se perdió contenido existente fuera de la sección de scripts")
		}

		// Verificar que la sección fue actualizada
		if !strings.Contains(string(content), newSection) {
			t.Error("No se actualizó la sección de scripts correctamente")
		}
	})

	t.Run("Agregar sección a README vacío", func(t *testing.T) {
		testPath := filepath.Join(tmpDir, "EMPTY_README.md")

		// Obtener descripciones
		descriptions, err := GetScriptDescriptions("bash_scripts")
		if err != nil {
			t.Fatal(err)
		}

		newSection := GenerateReadmeSection(descriptions)

		// Ejecutar en archivo nuevo
		updated, err := UpdateReadmeIfNeeded(newSection, testPath)
		if err != nil {
			t.Fatal(err)
		}

		if !updated {
			t.Error("Debió crear nuevo README")
		}

		content, err := os.ReadFile(testPath)
		if err != nil {
			t.Fatal(err)
		}

		if !strings.Contains(string(content), "## Available Scripts") {
			t.Error("No se creó la sección correctamente")
		}
	})
}
