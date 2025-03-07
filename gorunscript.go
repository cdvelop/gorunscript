package gorunscript

import (
	"embed"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

//go:embed bash_scripts/*.sh
var bash_scripts embed.FS

// ScriptRunner es un manejador para ejecutar scripts de diferentes tipos
type ScriptRunner struct {
	fsys           embed.FS
	baseDir        string
	interpreterCmd string
	cleanScripts   bool   // Indica si se deben limpiar los scripts después de ejecutarlos
	projectRoot    string // Ruta raíz del proyecto para configuración explícita
}

// NewBashRunner crea un manejador para scripts bash
func NewBashRunner() *ScriptRunner {
	// Comando por defecto
	interpreterCmd := "bash"

	if runtime.GOOS == "windows" {
		// Usar Git Bash directamente en Windows
		interpreterCmd = `C:\Program Files\Git\bin\bash.exe`
	}

	return &ScriptRunner{
		fsys:           bash_scripts,
		baseDir:        "bash_scripts",
		interpreterCmd: interpreterCmd,
		cleanScripts:   true, // Por defecto limpia los scripts
		projectRoot:    "",   // Por defecto no usa ruta específica
	}
}

// NewBashRunnerWithOptions crea un manejador para scripts bash con opciones avanzadas
func NewBashRunnerWithOptions(projectRoot string) *ScriptRunner {
	runner := NewBashRunner()
	runner.projectRoot = projectRoot
	return runner
}

// NewScriptRunner crea un manejador para scripts personalizados
func NewScriptRunner(fsys embed.FS, baseDir, interpreterCmd string) *ScriptRunner {
	return &ScriptRunner{
		fsys:           fsys,
		baseDir:        baseDir,
		interpreterCmd: interpreterCmd,
		cleanScripts:   true,
		projectRoot:    "",
	}
}

// SetKeepScripts configura si se deben mantener los scripts extraídos después de la ejecución
func (sr *ScriptRunner) SetKeepScripts(keep bool) {
	sr.cleanScripts = !keep
}

// getScriptsDir obtiene el directorio donde se extraerán los scripts
func getScriptsDir() (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("error obteniendo directorio de usuario: %w", err)
	}

	scriptDir := filepath.Join(homeDir, ".gorunscript")

	// Crear el directorio si no existe
	if err := os.MkdirAll(scriptDir, 0755); err != nil {
		return "", fmt.Errorf("error creando directorio para scripts: %w", err)
	}

	return scriptDir, nil
}

// ExecuteScript ejecuta un script y devuelve el código de salida y la salida del comando
func (sr *ScriptRunner) ExecuteScript(scriptName string, args ...string) (int, string, error) {
	// Asegurarse de que el nombre del script tiene extensión correcta
	if !strings.Contains(scriptName, ".") {
		scriptName = scriptName + ".sh"
	}

	// Obtener directorio para los scripts
	scriptsDir, err := getScriptsDir()
	if err != nil {
		return 1, "", err
	}

	// Limpiar el directorio de scripts antes de copiar/extraer nuevos scripts
	if err := os.RemoveAll(scriptsDir); err != nil {
		return 1, "", fmt.Errorf("error limpiando directorio de scripts: %w", err)
	}

	if err := os.MkdirAll(scriptsDir, 0755); err != nil {
		return 1, "", fmt.Errorf("error recreando directorio de scripts: %w", err)
	}

	// Si se ha proporcionado una ruta específica al proyecto, usamos esa para tests
	if sr.projectRoot != "" {
		// En tests, queremos usar los scripts reales del proyecto, no los embebidos
		srcDir := filepath.Join(sr.projectRoot, "bash_scripts")

		// Verificar que el directorio existe
		if _, err := os.Stat(srcDir); os.IsNotExist(err) {
			return 1, "", fmt.Errorf("error: directorio de scripts no encontrado en %s", srcDir)
		}

		// Listar y mostrar el contenido del directorio para debugging
		files, _ := os.ReadDir(srcDir)
		fileNames := make([]string, 0, len(files))
		for _, file := range files {
			fileNames = append(fileNames, file.Name())
		}
		fmt.Printf("Archivos en %s: %v\n", srcDir, fileNames)

		// Copiar los scripts directamente al directorio de scripts (sin subdirectorios)
		if err := copyDirContentsFlat(srcDir, scriptsDir); err != nil {
			return 1, "", fmt.Errorf("error copiando scripts: %w", err)
		}
	} else {
		// Extraer todos los scripts al directorio permanente desde el FS embebido
		if err := extractScriptsFlat(sr.fsys, sr.baseDir, scriptsDir); err != nil {
			return 1, "", fmt.Errorf("error extrayendo scripts: %w", err)
		}
	}

	// Limpiar los scripts al terminar si así se ha configurado
	if sr.cleanScripts {
		defer func() {
			_ = os.RemoveAll(scriptsDir)
			// Crear el directorio de nuevo para que esté listo para el próximo uso
			_ = os.MkdirAll(scriptsDir, 0755)
		}()
	}

	// Ruta al script principal en el directorio de scripts
	scriptPath := filepath.Join(scriptsDir, scriptName)

	// Verificar si el script existe
	if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
		// Listar archivos en el directorio para debugging
		files, _ := os.ReadDir(scriptsDir)
		fileNames := make([]string, 0, len(files))
		for _, file := range files {
			fileNames = append(fileNames, file.Name())
		}
		return 1, "", fmt.Errorf("error: el script '%s' no existe. Archivos disponibles: %v", scriptName, fileNames)
	}

	// Asegurarse de que todos los scripts son ejecutables
	if err := makeScriptsExecutable(scriptsDir); err != nil {
		return 1, "", fmt.Errorf("error haciendo los scripts ejecutables: %w", err)
	}

	var cmd *exec.Cmd

	if runtime.GOOS == "windows" {
		// Ejecutar script con Git Bash en Windows convirtiendo rutas a formato Unix
		unixPath := strings.ReplaceAll(scriptPath, "\\", "/")
		// Combine script path and arguments into a single quoted command string
		// Properly escape arguments and use bash positional parameters
		escapedArgs := make([]string, len(args))
		for i, arg := range args {
			escapedArgs[i] = fmt.Sprintf("%q", arg)
		}
		fullCommand := fmt.Sprintf("%q \"$@\"", unixPath)
		cmdArgs := []string{"-c", fullCommand, "--"}
		cmdArgs = append(cmdArgs, args...)
		cmd = exec.Command(sr.interpreterCmd, cmdArgs...)
	} else {
		// En otros sistemas ejecutar directamente
		cmd = exec.Command(sr.interpreterCmd, append([]string{scriptPath}, args...)...)
	}

	// Establecer el directorio de trabajo al directorio donde están los scripts
	cmd.Dir = scriptsDir

	// Configurar variables de entorno para asegurar la estabilidad
	env := os.Environ()
	cmd.Env = append(env, "LANG=C")

	// Ejecutar y capturar la salida
	output, err := cmd.CombinedOutput()
	outputStr := string(output)

	// Determinar el código de salida y manejar errores
	if err != nil {
		var exitCode int
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			exitCode = 1
		}
		return exitCode, outputStr, fmt.Errorf("error ejecutando script: %w", err)
	}

	return 0, outputStr, nil
}

// copyDirContentsFlat copia el contenido de un directorio a otro, sin mantener la estructura de subdirectorios
func copyDirContentsFlat(srcDir, destDir string) error {
	// Asegurarnos de que el directorio destino existe
	if err := os.MkdirAll(destDir, 0755); err != nil {
		return err
	}

	// Recorrer el directorio origen pero solo copiar los archivos del nivel superior
	files, err := os.ReadDir(srcDir)
	if err != nil {
		return fmt.Errorf("error al leer directorio %s: %w", srcDir, err)
	}

	for _, file := range files {
		if file.IsDir() {
			continue // Ignorar subdirectorios
		}

		srcPath := filepath.Join(srcDir, file.Name())
		destPath := filepath.Join(destDir, file.Name())

		// Copiar el archivo
		data, err := os.ReadFile(srcPath)
		if err != nil {
			return fmt.Errorf("error al leer archivo %s: %w", srcPath, err)
		}

		if err := os.WriteFile(destPath, data, 0644); err != nil {
			return fmt.Errorf("error al escribir archivo %s: %w", destPath, err)
		}
	}

	return nil
}

// extractScriptsFlat extrae todos los scripts del filesystem embebido al directorio de destino, sin mantener la estructura de subdirectorios
func extractScriptsFlat(fsys embed.FS, baseDir string, targetDir string) error {
	// Leer todos los archivos en el directorio base
	entries, err := fs.ReadDir(fsys, baseDir)
	if err != nil {
		return fmt.Errorf("error al leer directorio embebido %s: %w", baseDir, err)
	}

	// Extraer solo los archivos .sh del nivel superior
	for _, entry := range entries {
		if entry.IsDir() {
			continue // Ignorar subdirectorios
		}

		name := entry.Name()
		if !strings.HasSuffix(name, ".sh") {
			continue // Ignorar archivos que no sean .sh
		}

		// Leer el contenido del archivo
		content, err := fsys.ReadFile(filepath.Join(baseDir, name))
		if err != nil {
			return fmt.Errorf("error al leer archivo embebido %s: %w", name, err)
		}

		// Escribir el archivo en el directorio destino
		destPath := filepath.Join(targetDir, name)
		if err := os.WriteFile(destPath, content, 0644); err != nil {
			return fmt.Errorf("error al escribir archivo %s: %w", destPath, err)
		}
	}

	return nil
}

// makeScriptsExecutable hace todos los scripts en el directorio ejecutables
func makeScriptsExecutable(dirPath string) error {
	// En Windows no es necesario hacer los scripts ejecutables
	if runtime.GOOS == "windows" {
		return nil
	}

	return filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(path, ".sh") {
			if err := os.Chmod(path, 0755); err != nil {
				return fmt.Errorf("error al hacer ejecutable el script %s: %w", path, err)
			}
		}
		return nil
	})
}

// copyDirContents copia el contenido de un directorio a otro
func copyDirContents(srcDir, destDir string) error {
	// Asegurarnos de que el directorio destino existe
	if err := os.MkdirAll(destDir, 0755); err != nil {
		return err
	}

	// Recorrer el directorio origen
	err := filepath.Walk(srcDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Obtener la ruta relativa
		relPath, err := filepath.Rel(srcDir, path)
		if err != nil {
			return err
		}

		// Construir la ruta de destino
		destPath := filepath.Join(destDir, relPath)

		// Si es un directorio, crearlo
		if info.IsDir() {
			return os.MkdirAll(destPath, 0755)
		}

		// Si es un archivo, copiarlo
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}

		return os.WriteFile(destPath, data, 0644)
	})

	return err
}

// extractScripts extrae todos los scripts del filesystem embebido al directorio de destino
func extractScripts(fsys embed.FS, baseDir string, targetDir string) error {
	return fs.WalkDir(fsys, baseDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Crear la ruta de destino (relativa al directorio base)
		relPath, err := filepath.Rel(baseDir, path)
		if err != nil {
			return fmt.Errorf("error al obtener ruta relativa para %s: %w", path, err)
		}
		destPath := filepath.Join(targetDir, relPath)

		// Si es un directorio, créalo
		if d.IsDir() {
			return os.MkdirAll(destPath, 0755)
		}

		// Si es un archivo, extráelo
		content, err := fsys.ReadFile(path)
		if err != nil {
			return fmt.Errorf("error al leer el archivo %s: %w", path, err)
		}

		// Crear el archivo en el directorio de destino
		if err := os.WriteFile(destPath, content, 0644); err != nil {
			return fmt.Errorf("error al escribir el archivo %s: %w", destPath, err)
		}
		return nil
	})
}

// RunScript es una función de conveniencia para ejecutar scripts bash
func RunScript(scriptName string, args ...string) (int, string, error) {
	runner := NewBashRunner()
	return runner.ExecuteScript(scriptName, args...)
}
