package gorunsh

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestProjectRenaming(t *testing.T) {
	// Skip test if CI=true is not set - prevents accidental GitHub project creation
	if os.Getenv("RUN_GITHUB_TESTS") != "true" {
		t.Skip("Skipping test that creates GitHub projects. Set RUN_GITHUB_TESTS=true to run.")
	}

	// Extract scripts to temp directory
	scriptDir, err := ExtractScripts()
	if err != nil {
		t.Fatalf("Failed to extract scripts: %v", err)
	}
	defer os.RemoveAll(scriptDir)

	// Check if gh CLI is authenticated
	cmd := exec.Command("gh", "auth", "status")
	if err := cmd.Run(); err != nil {
		t.Skip("GitHub CLI not authenticated. Please run: gh auth login")
	}

	// Generate unique project names
	timestamp := time.Now().Format("20060102150405")
	origName := fmt.Sprintf("test-proj-%s", timestamp)
	newName := fmt.Sprintf("renamed-proj-%s", timestamp)

	// Create test directory structure
	testDir, err := os.MkdirTemp("", "go-rename-test-")
	if err != nil {
		t.Fatalf("Failed to create test directory: %v", err)
	}
	defer os.RemoveAll(testDir)

	packagesDir := filepath.Join(testDir, "Packages", "Internal")
	if err := os.MkdirAll(packagesDir, 0755); err != nil {
		t.Fatalf("Failed to create packages directory: %v", err)
	}

	// Navigate to the packages directory
	origDir, err := os.Getwd()
	if err != nil {
		t.Fatalf("Failed to get current directory: %v", err)
	}
	defer os.Chdir(origDir)

	if err := os.Chdir(packagesDir); err != nil {
		t.Fatalf("Failed to change directory: %v", err)
	}

	// Step 1: Create a new repository
	t.Logf("Creating test repository: %s", origName)
	output, err := RunScript(
		filepath.Join(scriptDir, "repo-remote-create.sh"),
		origName,
		"Test repository for rename operation",
		"public",
	)
	if err != nil {
		t.Fatalf("Failed to create repository: %v\nOutput: %s", err, output)
	}

	// Move into the project directory
	if err := os.Chdir(origName); err != nil {
		t.Fatalf("Failed to change directory to project: %v", err)
	}

	// Create a basic go.mod file
	t.Log("Creating go.mod file")
	cmd = exec.Command("go", "mod", "init", fmt.Sprintf("github.com/cdvelop/%s", origName))
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("Failed to initialize go module: %v\nOutput: %s", err, out)
	}

	// Create a simple Go file
	mainGo := `package main

import "fmt"

func main() {
    fmt.Println("Hello, world!")
}
`
	if err := os.WriteFile("main.go", []byte(mainGo), 0644); err != nil {
		t.Fatalf("Failed to write main.go: %v", err)
	}

	// Commit the changes
	cmd = exec.Command("git", "add", ".")
	if err := cmd.Run(); err != nil {
		t.Fatalf("Failed to git add: %v", err)
	}

	cmd = exec.Command("git", "commit", "-m", "Add go.mod and main.go")
	if err := cmd.Run(); err != nil {
		t.Fatalf("Failed to commit: %v", err)
	}

	cmd = exec.Command("git", "push")
	if err := cmd.Run(); err != nil {
		t.Fatalf("Failed to push: %v", err)
	}

	// Step 2: Rename the repository
	t.Logf("Renaming repository from %s to %s", origName, newName)
	output, err = RunScript(
		filepath.Join(scriptDir, "go-rename-project.sh"),
		origName,
		newName,
		"true", // Force rename
	)
	if err != nil {
		t.Fatalf("Failed to rename repository: %v\nOutput: %s", err, output)
	}

	// Verify the rename worked
	// 1. Check if current directory name changed
	currentDir, err := os.Getwd()
	if err != nil {
		t.Fatalf("Failed to get current directory: %v", err)
	}

	if !strings.HasSuffix(currentDir, newName) {
		t.Errorf("Expected directory to be renamed to %s, got %s", newName, currentDir)
	}

	// 2. Check if go.mod was updated
	goModContent, err := os.ReadFile("go.mod")
	if err != nil {
		t.Fatalf("Failed to read go.mod: %v", err)
	}

	expectedModulePath := fmt.Sprintf("module github.com/cdvelop/%s", newName)
	if !strings.Contains(string(goModContent), expectedModulePath) {
		t.Errorf("Expected go.mod to contain %q, got:\n%s", expectedModulePath, goModContent)
	}

	// Cleanup - delete the test repository
	t.Log("Cleaning up - deleting test repository")
	cmd = exec.Command("gh", "repo", "delete", fmt.Sprintf("cdvelop/%s", newName), "--yes")
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Logf("Warning: Failed to delete repository: %v\nOutput: %s", err, out)
	}
}
