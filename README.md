# GoRunScript

[![Go Reference](https://pkg.go.dev/badge/github.com/cdvelop/gorunscript.svg)](https://pkg.go.dev/github.com/cdvelop/gorunscript)

A lightweight Go library for seamlessly executing Bash scripts from your Go applications with powerful features for handling arguments, output, and error management.

## Features

- 🚀 Execute Bash scripts directly from Go code
- 🔄 Pass arguments to your scripts easily
- 📊 Capture exit codes, output text, and error information
- 🛠️ Support for custom functions and utilities in your scripts
- 🧪 Well-tested with comprehensive test coverage

## Installation

```bash
go get github.com/cdvelop/gorunscript
```

## Quick Start

```go
package main

import (
    "fmt"
    "github.com/cdvelop/gorunscript"
)

func main() {
    // Create a new Bash script runner
    runner := gorunscript.NewBashRunner()
    
    // Execute a script with arguments
    exitCode, output, err := runner.ExecuteScript("my-script", "arg1", "arg2")
    
    // Handle the results
    if err != nil {
        fmt.Printf("Error: %v (Exit code: %d)\n", err, exitCode)
        fmt.Printf("Output: %s\n", output)
    } else {
        fmt.Printf("Success! (Exit code: %d)\n", exitCode)
        fmt.Printf("Output: %s\n", output)
    }
}
```

## Usage

### Basic Usage

1. Create a script runner:

```go
// Default runner (searches for scripts in standard locations)
runner := gorunscript.NewBashRunner()

// Or specify a custom project root directory that contains bash_scripts/
runner := gorunscript.NewBashRunnerWithOptions("/path/to/project")
```

2. Execute a script:

```go
exitCode, output, err := runner.ExecuteScript("script-name", "arg1", "arg2")
```

3. Process the results:

```go
if err != nil {
    // Handle error
    log.Printf("Script execution failed: %v", err)
} else {
    // Process successful execution
    log.Printf("Script executed successfully with output: %s", output)
}
```

### Script Organization

Your Bash scripts should be placed in a `bash_scripts` directory in your project root:

```
your-go-project/
├── bash_scripts/
│   ├── script1.sh
│   ├── script2.sh
│   └── functions.sh  (optional shared functions)
└── main.go
```

### Shared Functions

You can create a `functions.sh` file in your `bash_scripts` directory with common utilities that can be used across all your scripts:

```bash
#!/bin/bash
# bash_scripts/functions.sh

# Display success message
success() {
    echo "=>OK $1"
}

# Display error message
error() {
    echo "¡ERROR! $1"
    exit 1
}

# Execute a command safely
execute() {
    echo "Ejecución exitosa del comando: $@"
    "$@" || error "Failed to execute: $@"
}
```

## Advanced Features

### Custom Project Root Detection

The library intelligently detects your project root, but you can always specify it explicitly:

```go
customRunner := gorunscript.NewBashRunnerWithOptions("/custom/project/path")
```

### Working with Exit Codes

```go
exitCode, output, err := runner.ExecuteScript("backup-script")
if exitCode != 0 {
    fmt.Printf("Backup failed with exit code %d\n", exitCode)
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

<!-- SCRIPTS_SECTION_START -->
## Available Scripts

| Script Name | Description |
|-------------|-------------|
| `tag.sh` | Shell script utility |
| `test-script.sh` | Shell script utility |
| `go-mod-update.sh` | Go language utilities, Dependency updates |
| `gonewproject.sh` | Go language utilities |
| `pu-old.sh` | Shell script utility |
| `repo-existing-setup.sh` | Repository management, System setup/config |
| `repo-remote-create.sh` | Repository management |
| `tag-go.sh` | Go language utilities |
| `vps-setup-004-ssh-security.sh` | System setup/config |
| `tags.sh` | Shell script utility |
| `-user.sh` | Shell script utility |
| `change-remote.sh` | Shell script utility |
| `go-upgrade.sh` | Go language utilities |
| `gotestadd.sh` | Go language utilities |
| `pkg-update.sh` | Dependency updates |
| `tag-all-rename.sh` | Shell script utility |
| `deltag.sh` | Shell script utility |
| `git-utils.sh` | Git operations |
| `pu.sh` | Shell script utility |
| `repo-rename.sh` | Repository management |
| `tag-ver.sh` | Shell script utility |
| `delete.sh` | Shell script utility |
| `goget.sh` | Go language utilities |
| `gomod-update.sh` | Dependency updates, Go language utilities |
| `go-rename-project.sh` | Go language utilities |
| `goget-all.sh` | Empty script file |
| `repo-local-init.sh` | Repository management |
| `functions.sh` | Shell script utility |
| `go-mod-init.sh` | Go language utilities |
| `gopu.sh` | Go language utilities |
| `tag-rename.sh` | Shell script utility |
| `vps-setup-003-ssh-change.sh` | System setup/config |
| `vps-setup-005-time.sh` | System setup/config |
| `rename.sh` | Shell script utility |
| `repo-remote-delete.sh` | Repository management |
| `syscall.sh` | Shell script utility |
| `tag-all-delete.sh` | Shell script utility |
| `test.sh` | Shell script utility |
| `vps-setup-002-add-ssh.sh` | System setup/config |
| `bkp.sh` | Shell script utility |
| `gomod-check.sh` | Go language utilities |
| `license-create.sh` | Shell script utility |
| `rem-tracking.sh` | Shell script utility |

<!-- SCRIPTS_SECTION_END -->